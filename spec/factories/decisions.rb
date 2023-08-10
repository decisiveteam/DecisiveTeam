FactoryBot.define do
  factory :decision do
    team
    question { Faker::Lorem.sentence }
    created_by { team.team_members.first.user }
  end
end
