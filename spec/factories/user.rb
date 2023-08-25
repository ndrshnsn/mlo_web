FactoryBot.define do
  factory :user do
    email { Faker::Internet::email }
    full_name { Faker::Name }
    nickname { Faker::Name::initials }
    password { "12qwaszxQW" }
    password_confirmation { "12qwaszxQW" }

    after :create do |user|
      user.skip_confirmation!
    end
  end
end