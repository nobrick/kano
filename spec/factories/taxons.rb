FactoryGirl.define do
  factory :taxon do
    handyman
    code 'electronic/lighting'

    factory :certified_taxon do
      certified_status { certified_status }
      reason_code { reason_code }
      reason_message { reason_message }
      certified_at { Time.now }
      certified_by
    end
  end
end
