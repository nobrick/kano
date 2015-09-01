FactoryGirl.define do
  factory :account do
    sequence(:email, 100) { |n| "user#{n}@example.com" }
    password 'abcdefg'
    phone '13107485555'
    name '曲'
  end
end
