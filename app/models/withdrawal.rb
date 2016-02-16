class Withdrawal < ActiveRecord::Base
  include AASM
  include AASM::Helper

  belongs_to :handyman
  belongs_to :authorizer, class_name: 'Account'
  belongs_to :unfrozen_record, class_name: 'BalanceRecord'
  has_one :balance_record, as: :adjustment_event
  validates :handyman, presence: true
  validates :unfrozen_record, presence: true
  validates :bank_code, presence: true
  validates :account_no, presence: true
  accepts_nested_attributes_for :balance_record

  # @!visibility private
  STATES = %w{ requested transferred declined }
  validates :state, presence: true
  validates :total, numericality: { greater_than: 0, message: '无效' },
    if: :unfrozen_record

  validate :total_must_be_eq_unfrozen_balance,
    if: 'to? :requested'
  validate :request_must_be_applied_at_permitted_dates,
    if: 'to? :requested'
  validate :requested_withdrawal_must_be_unique,
    if: 'to? :requested'

  validate :total_must_be_lt_or_eq_unfrozen_balance,
    if: 'to? :transferred'

  validates :reason_message, presence: true, if: 'to? :declined'

  def self.transferred_since(time)
    where(state: 'transferred').where('transferred_at >= ?', time)
  end

  def self.requested_since(time)
    where(state: 'requested').where('created_at >= ?', time)
  end

  def self.transferred_or_requested_since(time)
    query = '(state = ? AND transferred_at >= ?) OR ' +
      '(state = ? AND created_at >= ?)'
    where(query, 'transferred', time, 'requested', time)
  end

  # @method state
  #
  # Withdrawal states in AASM.
  # [initial]
  #     The withdrawal has just been initialized, and is not ready for
  #     persistence in this state.
  #
  # [requested]
  #     The withdrawal is requested by the handyman, but not yet authorized.
  #
  # [transferred]
  #     The withdrawal is authorized and transferred.
  #
  # [declined]
  #     The withdrawal is declined by the authorizer.


  # @!group AASM event methods

  # @method request
  #
  # Requests the withdrawal. The event is triggered when the withdrawal is
  # applied by the handyman and valid for persistence.


  # @method transfer
  #
  # Transfers the withdrawal. The event is triggered when the withdrawal is
  # approved by +authorizer+ and the transfer has been done. +transferred_at+
  # will be touched.


  # @method decline
  #
  # Declines the withdrawal. The event is triggered when the withdrawal is
  # invalid or inappropriate due to the +reason_message+ filled by
  # +authorizer+. +declined_at+ will be touched.

  # @!endgroup

  aasm column: 'state', no_direct_assignment: true do
    state :initial, initial: true
    STATES.each { |s| state s.to_sym }

    event :request do
      transitions from: :initial, to: :requested, after: :do_request
    end

    event :transfer do
      transitions from: :requested, to: :transferred, after: :do_transfer,
        if: [ :guard_authorizer! ]
    end

    event :decline do
      transitions from: :requested, to: :declined, after: :do_decline,
        if: [ :guard_authorizer! ]
    end
  end

  def self.unfrozen_date
    14.days.ago.end_of_day
  end

  private

  def do_request
    handyman.reload
    self.unfrozen_record = handyman.unfrozen_balance_record

    if unfrozen_record
      withdrawal_total = handyman.latest_balance_record.withdrawal_total
      self.total = unfrozen_record.online_income_total - withdrawal_total
    end
  end

  def do_transfer
    self.transferred_at = Time.now
    set_balance_record
  end

  def do_decline
    self.declined_at = Time.now
  end

  def readonly?
    state_was && state_was != 'requested'
  end

  def before_destroy
    raise ActiveRecord::ReadOnlyRecord
  end

  # Ensures that withdrawal total is equal to unfrozen balance.
  #
  # Triggered when transitioning into +requested+ state.
  def total_must_be_eq_unfrozen_balance
  end

  # Ensures that withdrawal total is less than or equal to unfrozen balance.
  #
  # Triggered when transitioning into +transferred+ state.
  def total_must_be_lt_or_eq_unfrozen_balance
  end

  # Ensures that no requested withdrawal but the current one may exist at a
  # time.
  #
  # Triggered when transitioning into +requested+ state.
  def requested_withdrawal_must_be_unique
    if handyman.withdrawals.requested.present?
      errors.add(:base, '您已经提交过提现申请，请等待审核')
    end
  end

  def request_must_be_applied_at_permitted_dates
    if [ 7, 14, 21, 28 ].exclude? Date.today.day
      errors.add(:base, '请在每月7、14、21、28日提交提现申请')
    end
  end

  def guard_authorizer!
    raise TransitionFailure, 'Authorizer is not present' if authorizer.nil?
    raise TransitionFailure, 'Permission denied' unless authorizer.admin?
    true
  end

  def set_balance_record
    self.balance_record_attributes = {}
    balance_record.handler = BalanceRecord::WithdrawalHandler.new(self)
  end
end

class TransitionFailure < RuntimeError; end
