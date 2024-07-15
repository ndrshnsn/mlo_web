FactoryBot.define do
  factory :game_card do
    game { nil }
    player_season { nil }
    club { nil }
    ycard { false }
    rcard { false }
  end
end
