FactoryBot.define do
  factory :def_country do
    name { Faker::Nation.capital_city }
  end
end