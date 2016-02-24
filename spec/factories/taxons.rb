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
        taxon.certify(create :admin)
      when 'declined'
        taxon.decline(create(:admin), 'out_of_date', 'message')
      end
    end
  end
end
