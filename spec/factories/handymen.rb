FactoryGirl.define do
  factory :handyman do
    transient { with_taxons false }
    sequence(:email, 100) { |n| "handyman#{n}@example.com" }
    password 'abcdefg'
    phone { "1#{rand(10**9...10**10)}" }
    name '小明'
    primary_address_attributes { attributes_for(:address) }

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
  end
end
