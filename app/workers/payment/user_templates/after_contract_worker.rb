class Payment::UserTemplates::AfterContractWorker
  include Sidekiq::Worker
  sidekiq_options retry: 0, dead: false

  def perform(order_id)
    return unless order_id
    order = Order.find(order_id)
    UserWechatApi.push_after_contract(order)
  end
end
