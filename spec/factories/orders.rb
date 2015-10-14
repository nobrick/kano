FactoryGirl.define do
  factory :order do
    transient { state 'requested' }
    user
    address
    taxon_code 'general'
    content 'content'
    arrives_at { 3.hours.since }

    trait :payment do
      user_total 500.00
      user_promo_total 0.00
      payment_total 500.00
      handyman_bonus_total 0.00
      handyman_total 500.00
    end

    before(:create) do |order, evaluator|
      case evaluator.state
      when 'requested'
        order.request!
      when 'contracted'
        order.request!
        order.handyman ||= create(:handyman)
        order.contract!
      end
    end

    factory(:requested_order) { state 'requested' }
    factory(:contracted_order) { state 'contracted' }
  end
end
