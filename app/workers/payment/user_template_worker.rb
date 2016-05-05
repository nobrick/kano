class Payment::UserTemplateWorker
  include Sidekiq::Worker
  sidekiq_options retry: 0, dead: false

  def perform(symbol, payment_id)
    raise ArgumentError if symbol.to_s != 'complete_order'
    return unless payment_id
    payment = Payment.find(payment_id)
    UserWechatApi.push_after_payment(payment)
  end
end
