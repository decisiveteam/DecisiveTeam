FactoryBot.define do
  factory :team do |user|
    name { Faker::Team.name }
    handle { name.gsub(/\W/, '').downcase }
    after(:create) do |team|
      team.team_members << FactoryBot.create(:team_member, team: team)
    end
  end
end
