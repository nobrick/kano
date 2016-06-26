FactoryGirl.define do
  factory :account do
    email { "account-#{rand(1...10**7)}@example.com" }
    password 'abcdefg'
    phone { "1#{rand(10**9...10**10)}" }
    name '曲'
    type 'User'
  end
end
