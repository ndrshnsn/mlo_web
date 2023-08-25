FactoryBot.define do
  factory :club, aliases: [:home, :visitor] do
    def_team
    user_season
  end
end