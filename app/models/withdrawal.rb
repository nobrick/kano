class Withdrawal < ActiveRecord::Base
  include AASM
  include AASM::Helper

  belongs_to :handyman
  belongs_to :authorizer, class_name: 'Account'
  belongs_to :unfrozen_record, class_name: 'BalanceRecord'
  has_one :balance_record, as: :adjustment_event
  scope :unverified, -> { where('verify_passed IS NULL') }
  scope :verified_failure, -> { where(verify_passed: false) }
  scope :unprocessed, -> { where(verify_passed: true, state: 'requested') }
  scope :processed, -> { where(state: %w(declined transferred)) }
  validates :handyman, presence: true
  validates :unfrozen_record, presence: true
  validates :account_no, presence: true
  validates :account_no, allow_blank: true, format: {
    with: /\A\d{16,19}\z/,
    message: '格式无效'
  }
  validates :bank_code, inclusion: {
    in: Withdrawal::Banking.bank_codes,
    message: '不能为空'
  }
  accepts_nested_attributes_for :balance_record

  # @!visibility private
  STATES = %w{ requested transferred declined }
  validates :state, presence: true
  validates :total, numericality: { greater_than: 0, message: '无效' },
    if: :unfrozen_record

  validate :request_must_be_applied_at_permitted_dates, if: 'to? :requested'
  validate :requested_withdrawal_must_be_unique, if: 'to? :requested'
  validates :reason_message, presence: true, if: 'to? :declined'
  validates! :authorizer, admin: { presence: true },
    if: 'to? [ :transferred, :declined ]'

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
  # applied by the handyman.


  # @method transfer
  #
  # Transfers the withdrawal. The event is triggered when the withdrawal is
  # approved by +authorizer+ and the transfer has been done. +transferred_at+
  # will be touched.


  # @method decline
  #
  # Declines the withdrawal. The event is triggered when the withdrawal is
  # invalid or inappropriate due to the +reason_message+ filled by the
  # +authorizer+. +declined_at+ will be touched.

  # @!endgroup

  aasm column: 'state', no_direct_assignment: true do
    state :initial, initial: true
    STATES.each { |s| state s.to_sym }

    event :request do
      transitions from: :initial, to: :requested, after: :do_request
    end

    event :transfer do
      transitions from: :requested, to: :transferred, after: :do_transfer
    end

    event :decline do
      transitions from: :requested, to: :declined, after: :do_decline
    end
  end

  def self.unfrozen_date
    14.days.ago.end_of_day
  end

  def self.permitted_days
    [ 7, 14, 21, 28 ]
  end

  def self.at_permitted_requesting_date?
    permitted_days.include? Date.today.day
  end

  # Next permitted requesting date.
  #
  # @return [Date] Next permitted date for withdrawal request.
  def self.next_permitted_requesting_date(date = Date.today)
    dates = permitted_days.flat_map do |day|
      [ date, date.next_month ].map { |d| d.change(day: day) }
    end
    dates.select { |d| d > date }.min.to_date
  end

  # Computes unfrozen balance for the specified handyman. If a block is given,
  # the unfrozen balance record and withdrawable balance for the handyman are
  # passed as yielding parameters.
  #
  # @return [Decimal] Unfrozen withdrawable balance for handyman.
  # @yield [unfrozen_record, unfrozen_balance]
  # @yield_param [BalanceRecord] unfrozen_record The handyman's unfrozen
  # balance record.
  # @yield_param [Decimal] unfrozen_balance The returned unfrozen withdrawable
  # balance for the handyman.
  def self.unfrozen_balance_for(handyman)
    handyman.reload
    unfrozen = handyman.unfrozen_balance_record
    last = handyman.last_balance_record
    u = unfrozen ? (unfrozen.online_income_total - last.withdrawal_total) : 0
    yield unfrozen, u if block_given?
    u
  end

  # Checks if there exists no other requesting withdrawal.
  #
  # @return [Boolean] Whether current withdrawal request is unique.
  def withdrawal_request_unique?
    requested = handyman.withdrawals.requested
    requested = requested.where.not(id: id) if persisted?
    requested.blank?
  end

  def declined_at_or_transferred_at
    transferred_at || declined_at
  end

  private

  def do_request
    Withdrawal.unfrozen_balance_for(handyman) do |u_record, u_balance|
      self.unfrozen_record = u_record
      self.total = u_balance
    end
  end

  def do_transfer
    set_balance_record
    self.transferred_at = Time.now
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

  def requested_withdrawal_must_be_unique
    unless withdrawal_request_unique?
      errors.add(:base, '您已经提交过提现申请，请等待审核')
    end
  end

  def request_must_be_applied_at_permitted_dates
    unless Withdrawal.at_permitted_requesting_date?
      errors.add(:base, '请在每月7、14、21、28日提交提现申请')
    end
  end

  def set_balance_record
    self.balance_record_attributes = {}
    balance_record.handler = BalanceRecord::WithdrawalHandler.new(self)
  end
end
