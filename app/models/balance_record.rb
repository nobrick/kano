class BalanceRecord < ActiveRecord::Base
  default_scope { order(created_at: :desc) }
  belongs_to :owner, polymorphic: true
  belongs_to :adjustment_event, polymorphic: true
  scope :for_payment, -> { where(adjustment_event_type: 'Payment') }
  scope :for_withdrawal, -> { where(adjustment_event_type: 'Withdrawal') }
  scope :in_cash, -> { where(in_cash: true) }
  scope :online, -> { where(in_cash: false) }

  def self.since(time)
    where('created_at >= ?', time)
  end

  def self.until(time)
    where('created_at <= ?', time)
  end

  def self.in_time_range(starts, ends)
    if ends.is_a? ActiveSupport::Duration
      starts, ends = *[ starts, starts + ends ].sort
    end
    where('created_at > ?', starts).where('created_at < ?', ends)
  end

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
  validates_presence_of *BALANCE_ATTRIBUTES, strict: true
  validate :balance_attributes_must_be_positive

  before_validation :update_balance_attributes
  after_create :set_handyman_last_balance_record
  attr_accessor :handler

  def update_balance_attributes
    handler.perform(self)
    raise 'Adjustment event is not present' if event.blank?
    raise 'Owner is not present' if owner.blank?
  end

  def around_records(options = {})
    duration = options.fetch(:max_duration, 5.days)
    after_limit = options.fetch(:after_limit, 5)
    before_limit = options.fetch(:before_limit, after_limit - 1)
    records = owner.balance_records

    left_records = records.in_time_range(created_at, -duration)
      .reorder(created_at: :desc)
      .limit(before_limit)
    records.in_time_range(created_at, duration)
      .reorder(created_at: :asc)
      .limit(after_limit)
      .union_all(BalanceRecord.unscope(:order).where(id: id))
      .union_all(left_records)
      .order(created_at: :desc)
  end

  private

  def set_handyman_last_balance_record
    owner.last_balance_record = self
    owner.save!
  end

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

  def balance_attributes_must_be_positive
    (BALANCE_ATTRIBUTES - [ :adjustment ]).each do |attr|
      next unless self[attr]
      errors.add(attr, 'should be positive') if self[attr] < 0
    end
  end

  def readonly?
    true if persisted?
  end

  def before_destroy
    raise ActiveRecord::ReadOnlyRecord
  end
end
