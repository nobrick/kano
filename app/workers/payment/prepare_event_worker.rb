class Payment::PrepareEventWorker
  include Sidekiq::Worker
  sidekiq_options retry: 0, dead: false

  def perform(payment_id)
    return unless payment_id
    payment = Payment.find(payment_id)
    logger.info payment.inspect
    payment.save_with_prepare!
  end
end
