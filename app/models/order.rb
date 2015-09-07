class Order < ActiveRecord::Base
  include AASM

  belongs_to :user
  belongs_to :handyman
  belongs_to :transferee_order, class_name: 'Order'
  belongs_to :transferor, class_name: 'Account'
  belongs_to :canceler, class_name: 'Account'

  validates :content, presence: true
  validates :arrives_at, presence: true
  validates! :user, presence: true
  validates! :taxon_code, presence: true
  validates! :state, presence: true
  validates! :payment_state, presence: true

  validates! :handyman, presence: true, if: 'to? :contracted'

  validates :transfer_reason, presence: true, if: 'to? :transferred'
  validates! :transfer_type, inclusion: %w{ user handyman other },
    if: 'to? :transferred'
  validates! :transferor, presence: true, if: 'to? :transferred'

  aasm column: 'state', no_direct_assignment: true do
    # requested: The order has been requested by the user yet not been contracted by a handyman.
    # contracted: The order has been contracted, but the user has not paid.
    # payment: The order is being paid by the user, and the payment process is not completed.
    # completed: The order has been paid by the user.
    # rated: The order is completed and the handyman is rated by the user.
    # reported: The handyman is reported by the user after the order is contracted.
    # transferred: The order has been transferred to another order.
    state :requested, initial: true
    state :contracted
    state :payment
    state :completed
    state :rated
    state :reported
    state :transferred

    event :contract do
      transitions from: :requested, to: :contracted,
        guard: :model_valid?, after: :do_contract
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
      transitions from: [ :contracted, :completed ], to: :reported
    end

    event :transfer do
      transitions from: :contracted, to: :transferred,
        guard: :model_valid?, after: :do_transfer
    end
  end

  # Disable no-persistence aasm event methods
  aasm.events.map(&:name).each do |method|
    define_method method do |*args|
      raise "Should call `#{method}!` with persistence instead of this method."
    end
  end

  private

  def do_contract(options = {})
    self.handyman = options[:handyman] || handyman
  end

  def do_transfer(*args)
    attrs = {
      user: user,
      taxon_code: taxon_code,
      content: content,
      arrives_at: arrives_at
    }
    self.transferee_order = Order.create!(attrs)
    self.transferred_at = transferee_order.created_at
  end

  def model_valid?(*args)
    return false if invalid?
    true
  rescue ActiveModel::StrictValidationFailed
    false
  end

  def to?(state)
    aasm.to_state == state
  end
end
