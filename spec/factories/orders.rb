FactoryGirl.define do
  factory :order do
    transient { state 'requested' }
    user
    address
    taxon_code 'general'
    content 'content'
    arrives_at 3.hours.since

    before(:create) do |order, evaluator|
      case evaluator.state
      when 'requested'
        order.request!
      when 'contracted'
        order.request!
        order.handyman ||= create(:handyman)
        order.contract!
      end
    end
  end
end
