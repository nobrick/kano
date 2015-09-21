FactoryGirl.define do
  factory :address do
    association :addressable, factory: :user
    code '430105'
    content '德雅路10号'
  end
end
