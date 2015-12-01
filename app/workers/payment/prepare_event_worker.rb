class Payment::PrepareEventWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5, dead: false
  sidekiq_retry_in do |count|
    (rand(6) + 7) * count + 3
  end

  def perform(payment_id)
    return unless payment_id
    payment = Payment.find(payment_id)
    logger.info payment.inspect
    payment.save_with_prepare!
  end
end
