class Payment::HandymanTemplates::AfterPaymentWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(payment_id)
    return unless payment_id
    payment = Payment.find(payment_id)
    HandymanWechatApi.push_after_payment(payment)
  end
end
