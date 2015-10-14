FactoryGirl.define do
  factory :payment do
    transient { state 'checkout' }
    association :order, factory: :contracted_order
    payment_method 'wechat'
    total '9.99'
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
        payment.process!
      end
    end

    factory(:pending_payment) { state 'pending' }
    factory(:cash_payment, traits: [ :cash ])
  end
end
