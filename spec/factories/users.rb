FactoryGirl.define do
  factory :user do
    primary_address_attributes { attributes_for(:address) }
    email { "user-#{rand(1...10**7)}@example.com" }
    password 'abcdefg'
    name '小明'
    phone { "1#{rand(10**9...10**10)}" }
    phone_verified_at { Time.now }

    trait :wechat do
      provider 'wechat'
      uid { "UID-#{rand(1...10**7)}" }
    end

    trait :unverified do
      phone nil
      phone_verified_at nil
    end
  end
end
