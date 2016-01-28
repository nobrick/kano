FactoryGirl.define do
  factory :admin, parent: :user, aliases: [:certified_by] do
    admin true
  end
end
