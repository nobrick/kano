FactoryGirl.define do
  factory :taxon do
    transient { state 'pending' }
    handyman
    code 'electronic/lighting'

    before(:create) do |taxon, evaluator|
      case evaluator.state.to_s
      when 'pending'
        taxon.requested_at ||= 1.day.ago
        taxon.state = 'under_review'
      when 'certified'
        taxon.certified_at ||= Time.now
        taxon.certified_by ||= create :admin
        taxon.state = 'success'
      when 'declined'
        taxon.reason_code ||= 'out_of_date'
        taxon.reason_message ||= 'message'
        taxon.declined_at ||= Time.now
        taxon.declined_by ||= create :admin
        taxon.state = 'failure'
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
