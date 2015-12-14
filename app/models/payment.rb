class Payment < ActiveRecord::Base
  include AASM
  include Redis::Objects
  include IdRandomizable

  belongs_to :order, touch: true
  belongs_to :payment_profile, polymorphic: true
  has_one :balance_record, as: :adjustment_event
  accepts_nested_attributes_for :order, update_only: true
  accepts_nested_attributes_for :balance_record
  delegate :user, :handyman, *(Order::PAYMENT_TOTAL_ATTRIBUTES), to: :order
  value :redis_pingpp_charge
  value :redis_pingpp_charge_fetched_at
  attr_accessor :pingpp_retrieve_min_interval
  after_commit :perform_async_prepare

  validates :order, presence: true, associated: true
  validates :payment_method, inclusion: { in: %w{ cash wechat pingpp_wx_pub } }
  validates :expires_at, presence: true

  # @!visibility private
  STATES = %w{ processing pending failed void completed }
  validates :state, inclusion: { in: STATES }

  # @method state
  #
  # Payment states in AASM.
  # [initial]
  #     The payment has just been initialized, and is not ready for persistence
  #     in this state.
  #
  # [processing]
  #     The payment is being processed (temporary, intended to prevent double
  #     submission).
  #
  # [pending]
  #     The payment has been processed but is not yet complete (ex. Authorized
  #     but not captured).
  #
  # [failed]
  #     The payment was rejected or invalid (ex. Credit card was declined).
  #
  # [void]
  #     The payment should not be counted against the order. (ex. Order
  #     canceled, or payment expired).
  #
  # [completed]
  #     The payment was completed. Only payments in this state count against
  #     the order total.


  # @!group AASM event methods

  # @method checkout
  #
  # Submits request to gateway and marks payment state as +:processing+ to
  # avoid double submission. This event will also transition associated
  # order into +:payment+ state.
  #
  # This event should not be used for _cash_ payments. Use +complete+ event
  # instead to finish up the cash payment directly.
  #
  # +prepare+ event will be asynchronously called when the payment is
  # processed by gateway.


  # @method prepare
  #
  # The +prepare+ event will be called when the non-cash payment is processed
  # by gateway. And the payment will be transitioned into +:pending+ state
  # after the event.
  #
  # User will be able to pay the bill after the event succeeds, in which the
  # pre-payment gateway order object (ex. +pingpp_charge+ for PingPP payment)
  # will be fetched and cached.


  # @method expire
  # Expires the payment.
  #
  # The payment is expired if the payment is in +pending+ state and the
  # current time is over the expiration time the gateway pre-payment object
  # _or_ the +:expires_at+ attribute specifies.
  #
  # The event will transition associated order back into +:contracted+ state
  # and set reason code for it if succeeds.


  # @method flunk
  # Fails the payment.
  #
  # The +flunk+ event will be called when the +processing+ or +pending+ payment
  # does not receive pre-payment gateway order object correctly and
  # consistently (ex. Getting pre-payment object fails, or the object refers an
  # +id+ for +user+ / +handyman+ / +order+ that is inconsistent with the
  # current payment).
  #
  # The payment will be transitioned into +:failed+ state
  # when the event triggered.


  # @method complete
  # Completes the payment.
  #
  # For _cash_ payment, the event is called directly after the payment has
  # been initialized.
  #
  # For _non-cash_ payment, the event is called by +check_and_complete!+
  # method after the user pays.
  #
  # The event will also call the associated complete event on the order and
  # transition it into +:completed+ state.

  # @!endgroup

  aasm column: 'state', no_direct_assignment: true do
    state :initial, initial: true
    STATES.each { |s| state s.to_sym }

    event :checkout do
      transitions from: :initial, to: :processing, after: :do_checkout,
        if: [ :not_in_cash?, :payment_validity_guard, :checkout_guard ]
    end

    event :prepare do
      transitions from: :processing, to: :pending, after: :do_prepare
    end

    event :cancel do
      transitions from: :processing, to: :void
      transitions from: :pending, to: :void
    end

    event :expire do
      transitions from: :pending, to: :void, after: :do_expire
    end

    event :flunk, after: :do_flunk do
      transitions from: :processing, to: :failed
      transitions from: :pending, to: :failed
    end

    event :complete, after: :do_complete, if: [ :payment_validity_guard ] do
      transitions from: :initial, to: :completed, if: [ :in_cash? ]
      transitions from: :pending, to: :completed
    end
  end

  # Checks if it is a cash payment.
  def in_cash?
    payment_method == 'cash'
  end

  # Checks if it is a non-cash payment.
  def not_in_cash?
    payment_method != 'cash'
  end

  # Checks if the payment is using +pingpp_wx_pub+ (PingPP WeChat Pub) method.
  def pingpp_wx_pub?
    payment_method == 'pingpp_wx_pub'
  end

  # Checks if the payment is using Wechat API method (unused currently).
  def wechat_api?
    payment_method == 'wechat'
  end

  # Fetches pre-payment data from gateway and transition into +:pending+ state
  # with persistence.
  #
  # This method will be called asynchronously by +Payment::PrepareEventWorker+.
  def save_with_prepare!
    return unless processing?
    with_lock { prepare && save! }
    true
  end

  # Checks and fails the +processing+ or +pending+ payment if it is invalid.
  #
  # ex. Getting pre-payment data fails, or pre-payment data is inconsistent
  # with current payment and associated order.
  #
  # @param options [Hash]
  # @option options [Boolean] :retry Retry +prepare+ once if invalid when true.
  # @see valid_pingpp_charge?
  def check_and_fail!(options = {})
    return false unless processing? || pending?
    if pingpp_wx_pub?
      return false if valid_pingpp_charge?
      if options.fetch(:retry, true)
        reset_pingpp_charge
        return false if valid_pingpp_charge?
      end
      # Fails the payment if it remains invalid.
      flunk && save!
      return true
    end
    false
  end

  # Checks and expires the payment transitioning into +:void+ state with
  # persistence if necessary.
  def check_and_expire!
    return false unless expired?

    # Retrieves and checks the latest charge object in case the payment has
    # been paid before the +expire+ event.
    return false if check_and_complete!(fetch_latest: true)
    expire && save!
    true
  end

  # Checks (and fetches if necessary) the payment state, and marks the payment
  # and the associated order as +:completed+ state with persistence if paid.
  def check_and_complete!(options = {})
    case aasm.current_state
    when :completed
      return true
    when :pending
      if pingpp_wx_pub? && valid_pingpp_charge? && pingpp_paid?(options)
        complete && save!
        return true
      end
    end
    false
  end

  # Triggers +flunk+ or +expire+ or +complete+ transition with persistence by
  # checking current payment condition.
  # @return [Symbol] The transition triggered.
  def check_and_transition!
    case
    when check_and_fail!
      :failed
    when check_and_expire!
      :expired
    when check_and_complete!
      :completed
    else
      :unchanged
    end
  end

  # Checks if the +pending+ payment is expired by timestamps either set by user
  # or returned by payment gateway.
  # @return +false+ for non-pending states.
  def expired?
    return false unless pending?
    return true if Time.now > expires_at
    if pingpp_wx_pub?
      time = Time.at(pingpp_charge['time_expire'])
      return true if Time.now > time
    end
    false
  end

  # Checks if the current payment is valid for the associated order.
  def valid_payment?
    return false if order.nil?
    return false if void? || failed?
    return false if order.valid_payment && order.valid_payment != self
    true
  end

  # PingPP gateway payment order object cached by Redis in JSON format.
  # @return [String]
  def pingpp_charge_json
    redis_pingpp_charge.value
  end

  # PingPP gateway payment order object cached by Redis.
  def pingpp_charge
    json = pingpp_charge_json
    return nil unless json
    JSON.parse(json)
  end

  # Checks if +pingpp_charge+ is consistent with current payment and order.
  #
  # The method verifies consistency of the following attributes for the charge
  # object:
  # - the presence of the +pingpp_charge+ object.
  # - +order_no+, which should be consistent with payment +created_at+ and +id+.
  # - +metadata+ attributes, including +user_id+, +handyman_id+, and +order_id+.
  def valid_pingpp_charge?
    charge = pingpp_charge
    return false if charge.nil?
    return false if charge['order_no'] != gateway_order_no
    metadata = charge['metadata']
    case
    when metadata.nil?,
         metadata['user_id'] != user.id,
         metadata['handyman_id'] != handyman.id,
         metadata['order_id'] != order.id
      false
    else
      true
    end
  end

  # Checks if the payment has been paid using PingPP method.
  def pingpp_paid?(options = {})
    return false unless pingpp_wx_pub?
    paid = pingpp_charge.try(:[], 'paid')
    return true if paid
    charge = if options[:fetch_latest]
               retrieve_pingpp_charge
             else
               retrieve_pingpp_charge_if_needed
             end
    charge['paid']
  end

  # Gateway payment order no, which is intended to be unique and consistent in
  # both server application and payment gateway.
  #
  # The method is used for creating or retrieving payment orders from gateway,
  # corresponding to certain unique attribute for gateway order objects (ex.
  # +order_no+ attribute for +PingPP::Charge+ objects).
  def gateway_order_no
    "#{created_at.strftime('%y%m%d%H%M')}#{id}"
  end

  private

  # Checks payment validity for +checkout+ and +complete+ events.
  def payment_validity_guard
    raise TransitionFailure, 'Invalid payment' unless valid_payment?
    true
  end

  # Checks if the order is in permitted states for +checkout+ event.
  def checkout_guard
    if [ 'contracted', 'payment' ].exclude?(order.state)
      raise TransitionFailure, 'Order state is invalid'
    end
    true
  end

  # Transitions the order into +:payment+ state for +checkout+ event.
  def do_checkout
    unless order.pay
      raise TransitionFailure, "Order pay failure: #{order_errors}"
    end
    true
  end

  # Sets the order with payment expiration info and transitions it back into
  # +:contracted+ state getting ready for new payments.
  def do_expire
    mark_as_invalid_payment('expired')
  end

  def do_flunk
    mark_as_invalid_payment('failed')
  end

  # Retrieves and caches gateway prepay order object for +prepare+ event.
  def do_prepare
    charge_pingpp_wx_pub(set_charge: true) if pingpp_wx_pub?
    true
  end

  # Records balance adjustments and triggers the associated +complete+ event
  # determined by payment method on the order.
  def do_complete
    set_balance_record
    success = if in_cash?
                order.complete_in_cash
              else
                order.complete
              end
    unless success
      raise TransitionFailure, "Order complete failure: #{order_errors}"
    end
    true
  end

  def mark_as_invalid_payment(invalid_code)
    unless order.unpay
      raise TransitionFailure, "Order unpay failure: #{order_errors}"
    end
    order.redis_last_payment_invalid_code.value = invalid_code
    set_pingpp_charge(nil) if pingpp_wx_pub?
    true
  end

  def set_balance_record
    self.balance_record_attributes = {}
    self.balance_record.adjustment_event = self
  end

  def set_pingpp_charge(charge)
    if charge
      redis_pingpp_charge_fetched_at.value = Time.now
      redis_pingpp_charge.value = charge.to_json
    else
      redis_pingpp_charge_fetched_at.value = nil
      redis_pingpp_charge.value = nil
    end
    charge
  end

  def reset_pingpp_charge
    redis_pingpp_charge.value = nil
    case aasm.current_state
    when :processing then prepare && save!
    when :pending then charge_pingpp_wx_pub(set_charge: true)
    end
  end

  def retrieve_pingpp_charge_if_needed
    @pingpp_retrieve_min_interval ||= 2.5
    min_interval = @pingpp_retrieve_min_interval.seconds
    time_string = redis_pingpp_charge_fetched_at.value
    timestamp = time_string ? Time.parse(time_string) : nil
    if pingpp_charge && timestamp && (Time.now - timestamp < min_interval)
      pingpp_charge
    else
      retrieve_pingpp_charge
    end
  end

  def retrieve_pingpp_charge
    charge_id = pingpp_charge['id']
    new_charge = Pingpp::Charge.retrieve(charge_id)
    raise 'charge_id is inconsistent' if charge_id != new_charge['id']
    set_pingpp_charge(new_charge)
  end

  def charge_pingpp_wx_pub(options = {})
    should_set_charge = options.fetch(:set_charge, true)
    unless user.provider == 'wechat'
      message = 'User is not registered on wechat platform'
      raise TransitionFailure, message
    end
    charge = Pingpp::Charge.create(params_for_pingpp_charge)
    set_pingpp_charge(charge) if should_set_charge
    charge
  end

  def params_for_pingpp_charge
    subject = "#{order.taxon_name} - #{order.content_in_short(12)}"
    body = "#{user.full_or_nickname} - #{handyman.full_or_nickname}" +
           " - #{order.content_in_short(30)} - N#{gateway_order_no}"
    {
      order_no:    gateway_order_no,
      app:         { id: Rails.application.secrets.pingpp_appid },
      channel:     'wx_pub',
      amount:      (payment_total * 100).to_i,
      client_ip:   user.current_sign_in_ip || user.last_sign_in_ip || '0.0.0.0',
      currency:    'cny',
      subject:     subject.first(30),
      body:        body.first(100),
      description: order.content_in_short(100),
      extra: {
        open_id: user.uid,
      },
      metadata: {
        payment_id:     id,
        order_id:       order.id,
        user_id:        user.id,
        handyman_id:    handyman.id,
        user_uid:       user.uid,
        handyman_uid:   handyman.uid,
        user_phone:     user.phone,
        handyman_phone: handyman.phone,
        handyman_data: {
          balance:    handyman.balance,
          cash_total: handyman.cash_total
        }.to_json
      }
    }
  end

  def perform_async_prepare
    Payment::PrepareEventWorker.perform_async(id) if processing?
  end

  def order_errors
    order.errors.full_messages.join('; ')
  end
end

class TransitionFailure < RuntimeError; end
