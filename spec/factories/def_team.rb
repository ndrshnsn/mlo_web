FactoryBot.define do
  factory :def_team do
    def_country 
    
    name { Faker::Team.name }
  end
end