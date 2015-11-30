class Order < ActiveRecord::Base
  include AASM
  include IdRandomizable

  # TODO Update :completes_at when order finishes
  belongs_to :user
  belongs_to :handyman
  belongs_to :transferee_order, class_name: 'Order'
  belongs_to :transferor, class_name: 'Account'
  belongs_to :canceler, class_name: 'Account'
  has_one :address, as: :addressable, dependent: :destroy
  has_many :payments

  # Has one non-void payment at most
  has_one :valid_payment,
    -> { where("state not in ('void', 'failed')") },
    class_name: 'Payment'

  # Has one ongoing payment
  has_one :ongoing_payment,
    -> { where("state not in ('void', 'failed', 'completed')") },
    class_name: 'Payment'

  accepts_nested_attributes_for :transferee_order
  accepts_nested_attributes_for :address
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
  validates :transfer_reason, presence: true, if: 'to? :transferred'
  validates :transfer_type, inclusion: %w{ user handyman other }, if: 'to? :transferred'
  validates :transferor, presence: true, if: 'to? :transferred'

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

  STATES = %w{ requested contracted payment completed rated reported transferred }
  validates :state, inclusion: { in: STATES }

  aasm column: 'state', no_direct_assignment: true do
    # initial: The order has just been initialized, and currently invalid for
    # persistence.
    #
    # requested: The order has been requested by the user yet not been
    # contracted by a handyman.
    #
    # closed: The order has been closed (ex. user revoked the request).
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
    #
    # transferred: The order has been transferred to another order.

    state :initial, initial: true
    STATES.each { |s| state s.to_sym }

    event :request do
      transitions from: :initial, to: :requested
    end

    event :contract do
      transitions from: :requested, to: :contracted, after: :do_contract
    end

    event :close do
      transitions from: :requested, to: :closed
    end

    event :pay do
      # First payment transition
      transitions from: :contracted, to: :payment
      # Transition again (ex. payment failed)
      transitions from: :payment, to: :payment
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

    event :transfer do
      transitions from: :contracted, to: :transferred, after: :do_transfer
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

  def content_in_short(max = 32)
    if content.length > max
      "#{content[0..max]}..."
    else
      content
    end
  end

  def pingpp_charge
    valid_payment.try(:pingpp_charge).try(:value)
  end

  private

  def do_contract(*args)
    self.contracted_at = Time.now
  end

  # TODO Close order on Wechat pay API.
  def do_transfer(*args)
    transferee = Order.new(
      user: user,
      taxon_code: taxon_code,
      content: content,
      arrives_at: arrives_at,
      address_attributes: {
        content: address.content,
        code: address.code
      }
    )

    transferee.request
    self.transferee_order = transferee
    self.transferred_at = Time.now
    # TODO Test #void persistence
    if ongoing_payment && !(ongoing_payment.void)
      raise 'Cannot close ongoing payment right not'
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
