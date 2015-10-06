FactoryGirl.define do
  factory :user do
    primary_address_attributes { attributes_for(:address) }
    sequence(:email, 100) { |n| "user#{n}@example.com" }
    password 'abcdefg'
    phone { "1#{rand(10**9...10**10)}" }
    name '小明'
  end
end
