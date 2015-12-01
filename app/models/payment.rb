class Payment < ActiveRecord::Base
  include AASM
  include Redis::Objects

  belongs_to :order, touch: true
  belongs_to :payment_profile, polymorphic: true
  has_one :balance_record, as: :adjustment_event
  accepts_nested_attributes_for :order, update_only: true
  accepts_nested_attributes_for :balance_record
  delegate :user, :handyman, *(Order::PAYMENT_TOTAL_ATTRIBUTES), to: :order
  value :redis_pingpp_charge
  value :redis_pingpp_charge_timestamp
  attr_accessor :pingpp_retrieve_min_interval
  after_commit :perform_async_prepare

  validates :order, presence: true, associated: true
  validates :payment_method, inclusion: { in: %w{ cash wechat pingpp_wx_pub } }
  # TODO Finish up logic for :expires_at
  validates :expires_at, presence: true
  # validates :payment_profile, presence: true, associated: true, unless: :in_cash?

  STATES = %w{ processing pending failed void completed }
  validates :state, inclusion: { in: STATES }

  aasm column: 'state', no_direct_assignment: true do
    # initial: The payment has just been initialized, and currently invalid for
    # persistence.
    #
    # processing: The payment is being processed (temporary, intended to
    # prevent double submission).
    #
    # pending: The payment has been processed but is not yet complete (ex.
    # authorized but not captured).
    #
    # failed: The payment was rejected (ex. credit card was declined).
    #
    # void: The payment should not be counted against the order. (ex. order
    # transfered or canceled).
    #
    # completed: The payment is completed. Only payments in this state count
    # against the order total.

    state :initial, initial: true
    STATES.each { |s| state s.to_sym }

    # Update states of the payment and associated order.
    # Async submit the payment request to gateway and mark payment state as
    # `processing` to avoid double submission.
    #
    # `Prepare` event will be async called when the payment is processed.
    event :checkout do
      transitions from: :initial, to: :processing, after: :do_checkout,
        if: [ :not_in_cash?, :order_validity_guard, :checkout_guard ]
    end

    # Get ready for user payments
    event :prepare do
      transitions from: :processing, to: :pending, after: :do_prepare
    end

    # Cancel payment
    event :void do
      transitions from: :processing, to: :void
    end

    # Get payment failure
    event :fail do
      transitions from: :pending, to: :failed
    end

    # Get payment success
    event :complete, after: :do_complete, if: [ :order_validity_guard ] do
      # Cash-only payment transition
      transitions from: :initial, to: :completed, if: [ :in_cash? ]
      # Non-cash payment transition
      transitions from: :pending, to: :completed
    end
  end

  def in_cash?
    payment_method == 'cash'
  end

  def not_in_cash?
    payment_method != 'cash'
  end

  def pingpp_wx_pub?
    payment_method == 'pingpp_wx_pub'
  end

  def wechat_api?
    payment_method == 'wechat'
  end

  # Fetch pre-payment data from gateway and transition to :pending state.
  #
  # This method will be called asynchronously by Payment::PrepareEventWorker.
  def save_with_prepare!
    return unless processing?
    with_lock { prepare && save! }
  end

  # Check (and fetch if necessary) the payment state, and transition to
  # :completed state if paid.
  def check_and_complete!
    case aasm.current_state
    when :completed
      return true
    when :pending
      if pingpp_wx_pub? && pingpp_paid?
        complete && save!
        return true
      end
    end
    false
  end

  def pingpp_charge_json
    redis_pingpp_charge.value
  end

  def pingpp_charge
    json = pingpp_charge_json
    return nil unless json
    JSON.parse(json)
  end

  private

  def order_validity_guard
    raise TransitionFailure, 'Order is not present' unless order
    if order.valid_payment && order.valid_payment != self
      raise TransitionFailure,
        'Order valid payment already exists, set it void or failed first'
    end
    true
  end

  def checkout_guard
    if [ 'contracted', 'payment' ].exclude?(order.state)
      raise TransitionFailure, 'Order state is invalid'
    end
    true
  end

  def do_checkout
    # Validate the order and transition to :payment state if necessary
    unless order.pay
      message = "Order payment failure: #{order.errors.full_messages.join('; ')}"
      raise TransitionFailure, message
    end
  end

  def do_prepare
    set_pingpp_charge(charge_pingpp_wx_pub) if pingpp_wx_pub?
  end

  def do_complete
    set_balance_record
    success = if in_cash?
                order.complete_in_cash
              else
                order.complete
              end
    unless success
      message = "Order complete failure: #{order.errors.full_messages.join('; ')}"
      raise TransitionFailure, message
    end
    true
  end

  def set_balance_record
    self.balance_record_attributes = {}
    self.balance_record.adjustment_event = self
  end

  def set_pingpp_charge(charge)
    redis_pingpp_charge_timestamp.value = Time.now
    redis_pingpp_charge.value = charge.to_json
    charge
  end

  def retrieve_pingpp_charge_if_needed
    @pingpp_retrieve_min_interval ||= 2.5
    min_interval = @pingpp_retrieve_min_interval.seconds
    time_string = redis_pingpp_charge_timestamp.value
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

  def pingpp_paid?
    paid = pingpp_charge.try(:[], 'paid')
    paid ||= retrieve_pingpp_charge_if_needed['paid']
  end


  def charge_pingpp_wx_pub
    unless user.provider == 'wechat'
      message = 'User is not registered on wechat platform'
      raise TransitionFailure, message
    end

    Pingpp::Charge.create(
      order_no:  order.id,
      app:       { id: Rails.application.secrets.pingpp_appid },
      channel:   'wx_pub',
      amount:    (payment_total * 100).to_i,
      client_ip: user.current_sign_in_ip || user.last_sign_in_ip || '127.0.0.1',
      currency:  'cny',
      subject:   order.content_in_short,
      body:      order.content,
      extra: {
        open_id: user.uid,
      }
    )
  end

  def perform_async_prepare
    Payment::PrepareEventWorker.perform_async(id) if processing?
  end
end

class TransitionFailure < RuntimeError; end
