FactoryGirl.define do
  factory :handyman do
    transient { with_taxons false }
    primary_address_attributes { attributes_for(:address) }
    sequence(:email, 100) { |n| "handyman#{n}@example.com" }
    password 'abcdefg'
    name '小明'
    phone { "1#{rand(10**9...10**10)}" }
    phone_verified_at { Time.now }

    after(:create) do |handyman, evaluator|
      codes = %w{ electronic/lighting water/faucet }
      case evaluator.with_taxons.to_s
      when 'certified'
        codes.each do |code|
          create :taxon, handyman: handyman, code: code, state: :certified
        end
      when 'pending', 'true'
        handyman.taxons_attributes = codes.map { |c| { code: c } }
        handyman.save!
      end
    end

    factory(:handyman_with_taxons) { with_taxons 'certified' }
    factory(:handyman_with_pending_taxons) { with_taxons 'pending' }
  end
end
