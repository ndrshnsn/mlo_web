FactoryBot.define do
  factory :season do
    league

    name { Faker::Team.creature }
    status { 0 }

  end
end