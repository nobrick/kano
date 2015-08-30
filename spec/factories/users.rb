FactoryGirl.define do
  factory :user do
    sequence(:email, 100) { |n| "user#{n}@example.com" }
    password 'abcdefg'
    name '曲'
  end
end
