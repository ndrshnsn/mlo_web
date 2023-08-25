FactoryBot.define do
  factory :championship do
    season

    name { Faker::Beer.hop }
    status { 0 }

  end
end