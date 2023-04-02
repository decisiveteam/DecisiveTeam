FactoryBot.define do
  factory :team do |user|
    name { Faker::Team.name }
    handle { name.gsub(/\W/, '').downcase }
  end
end
