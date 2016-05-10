module OrdersAssociation
  extend ActiveSupport::Concern

  included do
    has_many :orders

    with_options class_name: 'Order' do |v|
      v.has_many :finished_orders, -> { where(state: Order::FINISHED_STATES) }
      v.has_many :canceled_orders, -> { where(state: "canceled") }
      v.has_many :orders_under_processing, -> { where(state: Order::UNDER_PROCESSING_STATES) }
    end
  end
end

