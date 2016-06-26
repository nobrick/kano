FactoryGirl.define do
  factory :account do
    sequence(:email, 100) { |n| "account#{n}@example.com" }
    password 'abcdefg'
    phone { "1#{rand(10**9...10**10)}" }
    name '曲'
    type 'User'
  end
end
