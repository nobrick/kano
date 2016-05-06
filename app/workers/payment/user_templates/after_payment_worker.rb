class Payment::UserTemplates::AfterPaymentWorker
  include Sidekiq::Worker
  sidekiq_options retry: 0, dead: false

  def perform(payment_id)
    return unless payment_id
    payment = Payment.find(payment_id)
    UserWechatApi.push_after_payment(payment)
  end
end
