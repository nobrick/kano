class Order < ActiveRecord::Base
  include AASM
  include Redis::Objects
  include IdRandomizable

  # TODO Update :completes_at when order finishes
  belongs_to :user
  belongs_to :handyman
  belongs_to :canceler, class_name: 'Account'
  has_one :address, as: :addressable, dependent: :destroy
  has_many :payments

  # Has one non-void payment at most.
  has_one :valid_payment,
    -> { where("state not in ('void', 'failed')") },
    class_name: 'Payment'

  # Has one ongoing payment.
  has_one :ongoing_payment,
    -> { where("state not in ('void', 'failed', 'completed')") },
    class_name: 'Payment'

  accepts_nested_attributes_for :address

  # Reason code for last void or failed payment.
  #
  # +'expired'+ for payment expiration.
  # +'failed'+ for payment failure.
  # +'canceled'+ for payment cancellation.
  value :redis_last_payment_invalid_code

  before_validation :set_address
  after_touch :clear_association_cache

  validates :content, length: { minimum: 5 }
  validates :arrives_at, presence: true
  validates :user, presence: true
  validates :taxon_code, presence: true, inclusion: { in: Taxon.taxon_codes }
  validates :state, presence: true
  validates :address, presence: true, associated: true
  validates :arrives_at, inclusion: {
    in: (10.minute.from_now)..(30.days.from_now),
    message: '无效'
  }, if: 'to? :requested'
  validates :handyman, presence: true, associated: true, if: 'to? :contracted'
  validates :cancel_type, inclusion: { in: %w{ User Handyman Admin } }, if: 'to? :canceled'
  validates_presence_of :canceled_at, :canceler, if: 'to? :canceled'

  # Payment total attributes
  #
  # user_total: The total fee that displays to user.
  # equals to (payment_total + user_promo_total).
  #
  # payment_total: The total fee the user actually pays.
  #
  # user_promo_total: Discount for user.
  #
  # handyman_bonus_total: The extra reward for handyman.
  #
  # handyman_total: The total money the handyman gets.
  # equals to (user_total + handyman_bonus_total).
  # equals to (payment_total + user_promo_total + handyman_bonus_total).
  PAYMENT_TOTAL_ATTRIBUTES = [
    :user_total,
    :payment_total,
    :user_promo_total,
    :handyman_bonus_total,
    :handyman_total
  ]
  MAX_PAYMENT_AMOUNT = 1000
  validates_presence_of PAYMENT_TOTAL_ATTRIBUTES, if: 'to? :payment'
  validates_numericality_of PAYMENT_TOTAL_ATTRIBUTES,
    numericality: { greater_than_or_equal_to: 0, less_than: MAX_PAYMENT_AMOUNT },
    if: 'to? :payment'
  validate :check_payment_totals, if: 'to? :payment'

  STATES = %w{ requested contracted payment completed canceled rated reported }
  validates :state, inclusion: { in: STATES }

  aasm column: 'state', no_direct_assignment: true do
    # initial: The order has just been initialized, and currently invalid for
    # persistence.
    #
    # requested: The order has been requested by the user yet not been
    # contracted by a handyman.
    #
    # canceled: The order has been canceled (ex. user revoked the request).
    #
    # contracted: The order has been contracted, but the user has not paid.
    #
    # payment: The order is being paid by the user, and the payment process is
    # not completed.
    #
    # completed: The order has been paid by the user, but not yet rated.
    #
    # rated: The order is completed and the handyman is rated by the user.
    #
    # reported: The handyman service is reported by the user after the order is
    # contracted.

    state :initial, initial: true
    STATES.each { |s| state s.to_sym }

    event :request do
      transitions from: :initial, to: :requested
    end

    event :contract do
      transitions from: :requested, to: :contracted, after: :do_contract
    end

    event :cancel, after: :do_cancel do
      transitions from: :requested, to: :canceled
      transitions from: :contracted, to: :canceled
    end

    event :pay do
      transitions from: :contracted, to: :payment
      transitions from: :payment, to: :payment
    end

    event :unpay do
      transitions from: :payment, to: :contracted
      transitions from: :contracted, to: :contracted
    end

    event :complete do
      transitions from: :payment, to: :completed
    end

    event :complete_in_cash do
      transitions from: :contracted, to: :completed
    end

    event :rate do
      transitions from: :completed, to: :rated
    end

    event :report do
      transitions from: [ :contracted, :completed, :rated ], to: :reported
    end
  end

  def taxon_name
    @taxon_name ||= Taxon.taxon_name(taxon_code)
  end

  def category_name
    @category_name ||= Taxon.category_name(taxon_code.split('/').first)
  end

  def state_description
    I18n.translate "order.#{state}"
  end

  def sync_from_user_total
    self.user_promo_total ||= 0
    self.handyman_bonus_total ||= 0
    return false if user_total.nil? || user_total < 0
    t_payment_total = user_total - user_promo_total
    return false if t_payment_total < 0
    self.payment_total = t_payment_total
    self.handyman_total = user_total + handyman_bonus_total
    true
  end

  def content_in_short(max_length = 25)
    return '' if max_length < 4
    if content.length > max_length
      "#{content[0..(max_length - 4)]}..."
    else
      content
    end
  end

  def pingpp_charge_json
    valid_payment.try(:pingpp_charge_json)
  end

  def pingpp_charge
    valid_payment.try(:pingpp_charge)
  end

  def valid_pingpp_charge?
    return false if valid_payment.blank?
    valid_payment.valid_pingpp_charge?
  end

  def payment_expired?
    valid_payment.try(:expired?)
  end

  def build_payment(options = {})
    payment = Payment.new
    payment.order = self
    payment.expires_at = options[:expires_at] || 2.hours.since
    payment.payment_method = options[:payment_method]
    payment
  end

  private

  def do_contract(*args)
    self.contracted_at = Time.now
  end

  def do_cancel
    self.canceled_at = Time.now
    raise 'Canceler cannot be nil' if canceler.nil?
    self.cancel_type = if canceler.admin?
                         'Admin'
                       elsif canceler.is_a? Handyman
                         'Handyman'
                       else
                         'User'
                       end
  end

  def to?(state)
    aasm.to_state == state
  end

  def set_address
    self.address.addressable = self if address.present?
  end

  def check_payment_totals
    return if PAYMENT_TOTAL_ATTRIBUTES.any? { |m| send(m).nil? }
    if user_total != payment_total + user_promo_total
      errors.add(:user_total, 'should be sum of payment_total and user_promo_total')
    elsif  handyman_total != user_total + handyman_bonus_total
      errors.add(:handyman_total, 'should be sum of user_total and handyman_bonus_total')
    end
  end
end
