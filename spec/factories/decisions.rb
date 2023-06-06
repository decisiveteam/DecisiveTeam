FactoryBot.define do
  factory :decision do
    team
    question { Faker::Lorem.sentence }
    deadline { Faker::Time.forward(days: 7) }
    status { 'open' }
    created_by { team.team_members.first.user }
  end
end
