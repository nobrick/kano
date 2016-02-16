FactoryGirl.define do
  factory :withdrawal do
    transient { state 'requested' }
    handyman
    bank_code 'icbc'
    account_no '6212261901000001503'

    before(:create) do |withdrawal, evaluator|
      case evaluator.state
      when 'requested'
        withdrawal.request
      when 'transferred'
        withdrawal.request && withdrawal.save!
        withdrawal.authorizer = create :admin
        withdrawal.transfer
      when 'declined'
        withdrawal.request && withdrawal.save!
        withdrawal.authorizer = create :admin
        withdrawal.reason_message = 'reason'
        withdrawal.decline
      end
    end

    factory(:requested_withdrawal) { state 'requested' }
    factory(:transferred_withdrawal) { state 'transferred' }
    factory(:declined_withdrawal) { state 'declined' }
  end
end
