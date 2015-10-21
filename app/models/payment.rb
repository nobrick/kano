class Payment < ActiveRecord::Base
  include AASM

  belongs_to :order, touch: true
  belongs_to :payment_profile, polymorphic: true
  has_one :balance_record, as: :adjustment_event
  accepts_nested_attributes_for :order, update_only: true
  accepts_nested_attributes_for :balance_record
  delegate :user, :handyman, *(Order::PAYMENT_TOTAL_ATTRIBUTES), to: :order

  validates :order, presence: true, associated: true
  validates :payment_method, inclusion: { in: %w{ cash wechat } }
  # TODO Finish up logic for :expires_at
  validates :expires_at, presence: true
  # validates :payment_profile, presence: true, associated: true, unless: :in_cash?

  STATES = %w{ checkout processing pending failed void completed }
  validates :state, inclusion: { in: STATES }

  aasm column: 'state', no_direct_assignment: true do
    # initial: The payment has just been initialized, and currently invalid for
    # persistence.
    #
    # checkout: Checkout has not been completed.
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

    event :checkout do
      transitions from: :initial, to: :checkout, after: :do_checkout,
        if: [ :not_in_cash?, :order_validity_guard, :checkout_guard ]
    end

    event :process do
      transitions from: :checkout, to: :pending
    end

    event :void do
      transitions from: :checkout, to: :void
    end

    event :fail do
      transitions from: :pending, to: :failed
    end

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
    true
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

  private

  def set_balance_record
    self.balance_record_attributes = {}
    self.balance_record.adjustment_event = self
  end
end

class TransitionFailure < RuntimeError; end
