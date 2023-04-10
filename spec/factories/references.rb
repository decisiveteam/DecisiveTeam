FactoryBot.define do
  factory :reference do
    referencer { nil }
    referenced { nil }
    created_by { nil }
  end
end
