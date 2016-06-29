class Order::NoContractRemindWorker
  include Sidekiq::Worker
  sidekiq_options retry: 0, dead: false

  def perform(order_id)
    return unless order_id
    order = Order.find(order_id)
    if order.requested?
      Slack::OrderNotifier.push_uncontracted_order(order)
    end
  end
end
