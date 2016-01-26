FactoryGirl.define do
  factory :order do
    transient do
      state 'requested'
      amount { 85 + rand(1..50) * 10.0 }
      bonus_amount { rand(0..3) * 5.0 }
    end
    user
    address
    taxon_code 'electronic/lighting'
    content 'content'
    arrives_at { 3.hours.since }

    trait :payment do
      user_total { amount }
      user_promo_total 0.00
      payment_total { amount }
      handyman_bonus_total { bonus_amount }
      handyman_total { amount + bonus_amount }
    end

    before(:create) do |order, evaluator|
      case evaluator.state
      when 'requested'
        order.request && order.save!
      when 'contracted'
        order.request && order.save!
        order.handyman ||= create(:handyman)
        order.contract && order.save!
      end
    end

    factory(:requested_order) { state 'requested' }
    factory(:contracted_order) { state 'contracted' }
  end
end
