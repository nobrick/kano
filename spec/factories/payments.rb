FactoryGirl.define do
  factory :payment do
    transient { state 'checkout' }
    association :order, factory: [ :contracted_order, :payment ]
    payment_method 'wechat'
    expires_at 5.hours.since
    last_ip nil
    payment_profile nil
    trait(:cash) { payment_method 'cash' }

    before(:create) do |payment, evaluator|
      case evaluator.state
      when 'checkout'
        payment.checkout!
      when 'pending'
        payment.checkout!
        raise unless payment.process!
      when 'completed'
        payment.checkout!
        payment.process! unless payment.in_cash?
        raise unless payment.complete!
      end
    end

    factory(:pending_payment) { state 'pending' }
    factory(:completed_payment) { state 'completed' }
    factory(:cash_payment, traits: [ :cash ])
  end
end
