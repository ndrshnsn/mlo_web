FactoryBot.define do
  factory :league do
    user

    name { Faker::Beer.brand }
    status { true }
    
  end
end