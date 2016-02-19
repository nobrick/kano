FactoryGirl.define do
  factory :taxon do
    transient { state 'pending' }
    handyman
    code 'electronic/lighting'

    before(:create) do |taxon, evaluator|
      case evaluator.state.to_s
      when 'pending'
        taxon.pend
      when 'certified'
        taxon.certified_by ||= create :admin
        taxon.certify
      when 'declined'
        taxon.reason_code ||= 'out_of_date'
        taxon.reason_message ||= 'message'
        taxon.declined_by ||= create :admin
        taxon.decline
      end
    end

    factory :certified_taxon do
      certified_status { certified_status }
      reason_code { reason_code }
      reason_message { reason_message }
      certified_at { Time.now }
      certified_by
    end
  end
end
