class Order < ActiveRecord::Base
  include AASM
  include AASM::Helper
  include Redis::Objects
  include IdRandomizable

  belongs_to :user
  belongs_to :handyman
  belongs_to :canceler, class_name: 'Account'
  has_one :address, as: :addressable, dependent: :destroy
  has_many :payments

  with_options class_name: 'Payment' do |v|
    v.has_one :valid_payment,
      -> { where("state not in ('void', 'failed')") }

    v.has_one :ongoing_payment,
      -> { where("state not in ('void', 'failed', 'completed')") }

    v.has_one :completed_payment, -> { where(state: 'completed') }
  end

  scope :completed_in_month,
    -> { where('completed_at > ?', Time.now.beginning_of_month) }

  scope :paid_in_cash,
    -> { joins(:payments).merge(Payment.completed.in_cash) }

  scope :paid_by_pingpp,
    -> { joins(:payments).merge(Payment.completed.by_pingpp) }

  accepts_nested_attributes_for :address

  # Reason code for last void or failed payment.
  #
  # +'expired'+ for payment expiration.
  # +'failed'+ for payment failure.
  # +'canceled'+ for payment cancellation.
  value :redis_last_payment_invalid_code

  before_validation :set_address
  after_touch :clear_association_cache
  after_create :update_user_address

  validates :content, length: { minimum: 5 }
  validates :arrives_at, presence: true
  validates :user, presence: true
  validates :taxon_code, inclusion: { in: Taxon.taxon_codes, message: '不能为空' }
  validates :state, presence: true
  validates :address, presence: true, associated: true
  validates :arrives_at, inclusion: {
    in: ->(o) { (10.minute.from_now)..(30.days.from_now) },
    message: '无效'
  }, if: 'to? :requested'
  validate :service_must_be_available, if: 'to? :requested'
  validates :handyman, presence: true, associated: true, if: 'to? :contracted'
  validates :cancel_type, inclusion: { in: %w{ User Handyman Admin } }, if: 'to? :canceled'
  validates_presence_of :canceled_at, :canceler, if: 'to? :canceled'

  attr_reader :retained_errors
  validate :add_retained_errors

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

  # Max limit for :user_total attribute
  MAX_PAYMENT_AMOUNT = 1000

  with_options if: 'to? [ :payment, :completed ]' do |v|
    v.validates_presence_of *PAYMENT_TOTAL_ATTRIBUTES
    v.validates_numericality_of :user_total, less_than: MAX_PAYMENT_AMOUNT
    v.validates_numericality_of :user_total,
      greater_than_or_equal_to: -> (o) { o.pricing[:total_price] }
    v.validate :check_payment_totals
  end

  STATES = %w{ requested contracted payment completed canceled rated reported }
  FINISHED_STATES = %w{ completed rated }
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
      transitions from: :payment, to: :completed, after: :do_complete
    end

    event :complete_in_cash do
      transitions from: :contracted, to: :completed,
        after: :do_complete_in_cash
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

  def sync_from_user_total(options = {})
    t_total = options[:user_total]
    self.user_total = t_total if t_total
    t_bonus_total = options[:handyman_bonus_total]
    self.handyman_bonus_total = t_bonus_total if t_bonus_total

    reset_bonus = options.fetch(:reset_bonus, false)
    self.user_promo_total = 0 if user_promo_total.nil? || reset_bonus
    self.handyman_bonus_total = 0 if handyman_bonus_total.nil? || reset_bonus

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

  def arrives_at_valid?(time = Time.now)
    (requested? || contracted?) && arrives_at >= time
  end

  def arrives_at_expired?(time = Time.now)
    (requested? || contracted?) && arrives_at < time
  end

  def pricing(options = {})
    city_pricing = TaxonItem.prices[address.city_code]
    return nil if city_pricing.blank? || city_pricing[taxon_code].blank?
    info = {
      traffic_price: city_pricing['_traffic'],
      taxon_price: city_pricing[taxon_code],
      hour_arrives_at: arrives_at.hour
    }
    if options.fetch(:calculate, true)
      times = case arrives_at.hour
              when 8...20 then 1
              when 20...22 then 1.2
              else 1.5
              end
      service_price = info[:taxon_price] * times
      info.merge!({
        times: times,
        night_mode: times > 1,
        service_price: service_price,
        total_price: info[:traffic_price] + service_price
      })
    end

    info
  end

  def retained_errors
    @retained_errors ||= ActiveModel::Errors.new(self)
  end

  def save_with_user_phone(phone)
    return save if user.phone == phone && user.phone_verified?
    transaction { user.update!(phone: phone) if save }
  rescue ActiveRecord::RecordInvalid
    user.errors.each { |a, e| errors.add a, e }
    false
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

  def do_complete_in_cash
    condition = handyman_bonus_total == 0 && user_promo_total == 0
    raise 'bonus must be zero for cash payment' unless condition
    do_complete(true)
    true
  end

  def do_complete(in_cash = false)
    self.completed_at = Time.now
  end

  def set_address
    self.address.addressable = self if address.present?
  end

  def update_user_address
    return true unless requested?
    user_addresses = user.addresses.lookup(address)
    if user_addresses.present?
      user_address = user_addresses.first
      return true if user_address == user.primary_address
      user.update!(primary_address_id: user_address.id)
    else
      user.update!(primary_address_attributes: address.attribute_hash)
    end
  end

  def check_payment_totals
    return if PAYMENT_TOTAL_ATTRIBUTES.any? { |m| send(m).nil? }
    if user_total != payment_total + user_promo_total
      errors.add(:user_total, 'should be sum of payment_total and user_promo_total')
    elsif handyman_total != user_total + handyman_bonus_total
      errors.add(:handyman_total, 'should be sum of user_total and handyman_bonus_total')
    end
  end

  def add_retained_errors
    retained_errors.each { |a, e| errors.add a, e }
  end

  def service_must_be_available
    return unless address || taxon_code
    city_pricing = TaxonItem.prices[address.city_code]
    if city_pricing.blank?
      errors.add(:base, '暂不支持您所在的城市')
    elsif TaxonItem.prices[taxon_code]
      errors.add(:base, '您所在的城市暂未开通该服务')
    end
  end
end
