FactoryGirl.define do
  factory :order do
    user
    taxon_code 'general'
    content 'content'
    arrives_at 3.hours.since
  end
end
