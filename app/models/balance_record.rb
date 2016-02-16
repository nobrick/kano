class BalanceRecord < ActiveRecord::Base
  default_scope { order(created_at: :desc) }
  belongs_to :owner, polymorphic: true
  belongs_to :adjustment_event, polymorphic: true
  scope :for_payment, -> { where(adjustment_event_type: 'Payment') }
  scope :for_withdrawal, -> { where(adjustment_event_type: 'Withdrawal') }
  scope :in_cash, -> { where(in_cash: true) }
  scope :online, -> { where(in_cash: false) }
  scope :until, -> (time) { where('created_at <= ?', time) }
  alias_attribute :event, :adjustment_event
  validates :owner, presence: true, associated: true
  validates :adjustment_event, presence: true, associated: true
  validate :check_adjustment_event

  # [balance]
  #     Current balance total including handyman bonus.
  # [prev_balance]
  #     Previous balance total including handyman bonus.
  # [cash_total]
  #     Current cash total.
  # [prev_cash_total]
  #     Previous cash total.
  # [adjustment]
  #     Adjustment total including handyman bonus.
  # [withdrawal_total]
  #     Current withdrawal total.
  # [prev_withdrawal_total]
  #     Previous withdrawal total.
  # [online_income_total]
  #     Current online income total.
  # [prev_online_income_total]
  #     Previous online income total.
  # [bonus_sum_total]
  #     Current accumulated handyman bonus total.
  # [prev_bonus_sum_total]
  #     Previous accumulated handyman bonus total.
  BALANCE_ATTRIBUTES = [
    :balance,
    :prev_balance,
    :cash_total,
    :prev_cash_total,
    :adjustment,
    :withdrawal_total,
    :prev_withdrawal_total,
    :online_income_total,
    :prev_online_income_total,
    :bonus_sum_total,
    :prev_bonus_sum_total
  ]
  validates_presence_of BALANCE_ATTRIBUTES, strict: true
  before_validation :update_balance_attributes
  attr_accessor :handler

  def update_balance_attributes
    handler.perform(self)
    raise 'Adjustment event is not present' if event.blank?
    raise 'Owner is not present' if owner.blank?
  end

  private

  def check_adjustment_event
    case event
    when Payment
      unless event.completed? || event.aasm.to_state == :completed
        raise 'Illegal payment state'
      end
    when Withdrawal
      true
    else
      raise 'Invalid adjustment event type'
    end
  end

  def readonly?
    true if persisted?
  end

  def before_destroy
    raise ActiveRecord::ReadOnlyRecord
  end
end
