class Payment::HandymanTemplateWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(symbol, payment_id)
    raise ArgumentError if symbol.to_s != 'complete_order'
    return unless payment_id
    payment = Payment.find(payment_id)
    HandymanWechatApi.push_after_payment(payment)
  end
end
