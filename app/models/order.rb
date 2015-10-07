class Order < ActiveRecord::Base
  include AASM

  belongs_to :user
  belongs_to :handyman
  belongs_to :transferee_order, class_name: 'Order'
  belongs_to :transferor, class_name: 'Account'
  belongs_to :canceler, class_name: 'Account'
  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :transferee_order
  accepts_nested_attributes_for :address
  after_initialize :set_payment_state
  before_validation :set_address

  validates :content, length: { minimum: 5 }
  validates :arrives_at, presence: true
  validates :user, presence: true, associated: true
  validates :taxon_code, presence: true
  validates :state, presence: true
  validates :payment_state, presence: true
  validates :address, presence: true, associated: true
  validates :arrives_at, inclusion: {
    in: (10.minute.from_now)..(30.days.from_now),
    message: '无效'
  }, if: 'to? :requested'
  validates :handyman, presence: true, associated: true, if: 'to? :contracted'
  validates :transfer_reason, presence: true, if: 'to? :transferred'
  validates :transfer_type, inclusion: %w{ user handyman other }, if: 'to? :transferred'
  validates :transferor, presence: true, if: 'to? :transferred'

  STATES = %w{ requested contracted payment completed rated reported transferred }
  validates :state, inclusion: { in: STATES }

  aasm column: 'state', no_direct_assignment: true do
    # initial: The order has just been created, and currently invalid for persistence.
    # requested: The order has been requested by the user yet not been contracted by a handyman.
    # contracted: The order has been contracted, but the user has not paid.
    # payment: The order is being paid by the user, and the payment process is not completed.
    # completed: The order has been paid by the user.
    # rated: The order is completed and the handyman is rated by the user.
    # reported: The handyman is reported by the user after the order is contracted.
    # transferred: The order has been transferred to another order.
    state :initial, initial: true
    STATES.each { |s| state s.to_sym }

    event :request do
      transitions from: :initial, to: :requested
    end

    event :contract do
      transitions from: :requested, to: :contracted, after: :do_contract
    end

    event :pay do
      transitions from: :contracted, to: :payment
    end

    event :finish do
      transitions from: :payment, to: :completed
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

  # Disable no-persistence aasm event methods
  aasm.events.map(&:name).each do |method|
    define_method method do |*args|
      raise "Should call `#{method}!` with persistence instead of this method."
    end
  end

  def self.taxons_for_select
    [ [ '类别1', 'type1' ], [ '类别2', 'type2' ], [ '类别3', 'type3' ] ]
  end

  def state_description
    I18n.translate "order.#{state}"
  end

  private

  def do_contract(*args)
    self.contracted_at = Time.now
  end

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

    transaction(requires_new: true) do
      raise 'Transferee request failure' unless transferee.request!
      self.transferee_order = transferee
      self.transferred_at = Time.now
      self.save!
    end
  rescue ActiveRecord::RecordInvalid => e
    self.transferee_order = nil
    self.transferred_at = nil
    raise e if args.last.try(:fetch, :raise, nil)
    false
  end

  def to?(state)
    aasm.to_state == state
  end

  def set_payment_state
    self.payment_state ||= 'initial'
  end

  def set_address
    self.address.addressable = self if address.present?
  end
end
