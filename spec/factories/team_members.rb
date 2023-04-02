FactoryBot.define do
  factory :team_member do
    association :user
    association :team
  end
end
