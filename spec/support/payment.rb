module Payment::TestHelpers
  def checkout_payment!(payment)
    payment.checkout && payment.save!
    payment
  end

  def prepare_payment!(payment, options = {})
    if payment.pingpp_wx_pub?
      allow(Pingpp::Charge).to receive(:create)
        .and_return(unpaid_hash_for(payment, options))
      payment.save_with_prepare!
      allow(Pingpp::Charge).to receive(:create).and_call_original
    else
      payment.save_with_prepare!
    end
    payment
  end

  def complete_payment!(payment)
    allow(Pingpp::Charge).to receive(:retrieve)
      .and_return(paid_hash_for(payment))
    payment.check_and_complete!(fetch_latest: true)
    allow(Pingpp::Charge).to receive(:retrieve).and_call_original
    payment
  end

  def unpaid_hash_for(payment, options = {})
    time_expire = (options[:expired] ? 1.second.ago : 2.hours.since).to_i
    {
      'order_no' => payment.gateway_order_no,
      'paid' => false,
      'time_expire' => time_expire,
      'metadata' => {
        'user_id' => payment.user.id,
        'handyman_id' => payment.handyman.id,
        'order_id' => payment.order.id
      }
    }
  end

  def paid_hash_for(payment)
    unpaid_hash_for(payment).merge('paid' => true)
  end
end

RSpec.configure do |config|
  config.include Payment::TestHelpers
end
