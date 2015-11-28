FactoryGirl.define do
  factory :handyman do
    transient { with_taxons false }
    sequence(:email, 100) { |n| "handyman#{n}@example.com" }
    password 'abcdefg'
    phone { "1#{rand(10**9...10**10)}" }
    name '小明'
    primary_address_attributes { attributes_for(:address) }

    after(:create) do |handyman, evaluator|
      if evaluator.with_taxons
        handyman.taxons_attributes = [
          { code: 'electronic/lighting' },
          { code: 'water/faucet' }
        ]
        handyman.save!
      end
    end

    factory(:handyman_with_taxons) { with_taxons true }
  end
end
