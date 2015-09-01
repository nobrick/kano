FactoryGirl.define do
  factory :handyman do
    sequence(:email, 100) { |n| "user#{n}@example.com" }
    password 'abcdefg'
    phone '13107485555'
    name '小明'
  end
end
