FactoryGirl.define do
  factory :payment do
    transient { state 'checkout' }
    association :order, factory: [ :contracted_order, :payment ]
    payment_method 'wechat'
    expires_at 5.hours.since
    last_ip nil
    payment_profile nil
    trait(:cash) { payment_method 'cash' }
    trait(:pingpp_wx_pub) { payment_method 'pingpp_wx_pub' }

    before(:create) do |payment, evaluator|
      case evaluator.state
      when 'processing'
        payment.checkout
      when 'pending'
        payment.checkout && payment.save!
        payment.prepare
      when 'completed'
        if payment.not_in_cash?
          payment.checkout && payment.save!
          payment.prepare && payment.save!
        end
        payment.complete
      end
    end

    factory(:pending_payment) { state 'pending' }
    factory(:completed_payment) { state 'completed' }
    factory(:cash_payment, traits: [ :cash ])
    factory(:pingpp_wx_pub_payment, traits: [ :pingpp_wx_pub ])
  end
end
