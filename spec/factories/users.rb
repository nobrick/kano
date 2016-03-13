FactoryGirl.define do
  factory :user do
    primary_address_attributes { attributes_for(:address) }
    sequence(:email, 100) { |n| "user#{n}@example.com" }
    password 'abcdefg'
    name '小明'
    phone { "1#{rand(10**9...10**10)}" }
    phone_verified_at { Time.now }

    trait :wechat do
      provider 'wechat'
      sequence(:uid, 100) { |n| "BXxFyinSQsyM5r6EOUJRmebAM#{n}" }
    end

    trait :unverified do
      phone nil
      phone_verified_at nil
    end
  end
end
