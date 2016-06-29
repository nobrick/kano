class Order::ExpiredCancelingWorker
  include Sidekiq::Worker
  sidekiq_options retry: 0, dead: false
  attr_reader :order

  def perform(order_id, days_to_expire)
    return unless order_id
    if expire_order(order_id, days_to_expire)
      Slack::OrderNotifier.push_expired_order(order)
    end
  end

  private

  def expire_order(order_id, days_to_expire)
    Order.serializable do
      set_order(order_id)
      return unless order.requested?
      return unless Time.now - order.created_at > days_to_expire.days - 1.hour
      cancel_order
    end
  end

  def set_order(order_id)
    @order = Order.find(order_id)
  end

  def cancel_order
    order.canceler = order.user
    order.cancel_type = 'System'
    order.may_cancel? && order.cancel && order.save
  end
end
