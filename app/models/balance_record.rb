class BalanceRecord < ActiveRecord::Base
  belongs_to :owner, polymorphic: true #, touch: true
  belongs_to :adjustment_event, polymorphic: true
  alias_attribute :event, :adjustment_event
  validates :owner, presence: true, associated: true
  validates :adjustment_event, presence: true, associated: true
  validate :check_adjustment_event

  # [balance]
  #     Current balance total including handyman bonus.
  # [previous_balance]
  #     Previous balance total including handyman bonus.
  # [cash_total]
  #     Current cash total.
  # [previous_cash_total]
  #     Previous cash total.
  # [adjustment]
  #     Adjustment total including handyman bonus.
  # [base_adjustment]
  #     Adjustment total excluding handyman bonus.
  # [base_balance]
  #     Current balance total excluding handyman bonus.
  # [previous_base_balance]
  #     Previous balance total excluding handyman bonus.
  BALANCE_ATTRIBUTES = [
    :balance,
    :previous_balance,
    :cash_total,
    :previous_cash_total,
    :adjustment,
    :base_adjustment,
    :base_balance,
    :previous_base_balance
  ]
  validates_presence_of BALANCE_ATTRIBUTES, strict: true
  before_validation :update_balance_attributes

  def update_balance_attributes
    raise 'Adjustment event is not present' if event.blank?
    self.owner = event.handyman
    raise 'Owner is not present' if owner.blank?
    return if last_record == self
    update_previous_attributes
    update_current_attributes
  end

  private

  def last_record
    # @last_record ||= owner.latest_balance_record
    @last_record ||= owner.reload.latest_balance_record
  end

  def update_previous_attributes
    if last_record
      self.previous_balance = last_record.balance
      self.previous_base_balance = last_record.base_balance
      self.previous_cash_total = last_record.cash_total
    else
      self.previous_balance = 0.00
      self.previous_base_balance = 0.00
      self.previous_cash_total = 0.00
    end
  end

  def update_current_attributes
    self.in_cash = event.in_cash?
    self.adjustment = event.handyman_total
    self.base_adjustment = event.user_total
    if in_cash?
      self.balance = previous_balance
      self.base_balance = previous_base_balance
      self.cash_total = previous_cash_total + adjustment
    else
      self.balance = previous_balance + adjustment
      self.base_balance = previous_base_balance + base_adjustment
      self.cash_total = previous_cash_total
    end
  end

  def check_adjustment_event
    # Only support Payment currently, may support Withdraw later.
    raise 'Invalid adjustment event type' unless event.is_a? Payment
    # Ensure record can only be created by Payment `complete` event
    unless event.completed? || event.aasm.to_state == :completed
      raise 'Illegal adjustment event state'
    end
  end

  def readonly?
    true if persisted?
  end

  def before_destroy
    raise ActiveRecord::ReadOnlyRecord
  end
end
