class DefPlayer < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :scoped, scope: :platform
  #has_noticed_notifications

  ## Player Attributes
  jsonb_accessor :details,
    platformid: :integer,
    attrs: [:jsonb, array: true, default: []],
    positions: [:string, array: true, default: []],

    ## PES ATTRS
    skills: [:string, array: true, default: []],
    com_styles: [:string, array: true, default: []],

    ## FIFA ATTRS
    specialities: [:string, array: true, default: []],
    traits: [:string, array: true, default: []]

  belongs_to :def_country
  belongs_to :def_player_position

  has_many :player_seasons
  has_many :club_players, through: :player_seasons

  def slug_candidates
    [
      :name,
      [:name, Faker::Name.last_name]
    ]
  end

  def self.getSeasonInitialSalary(season = nil, player = nil, coalesce_string = nil)
    if season
      return season.default_player_earnings_fixed if season.preferences["default_player_earnings"] == "fixed"
        
      if season.preferences["default_player_earnings"] == "proportional"
        sMultiplier = "1.0#{player.details["attrs"]["overallRating"]}".to_f
        return ((player.details["attrs"]["overallRating"] * sMultiplier) * 100).round(0).to_money
      end
    end

    if coalesce_string
      ## make sure to reflect any above changes
      "((def_players.details->'attrs'->>'overallRating')::Integer * (cast(cast('1.0' as text)||cast(def_players.details->'attrs'->>'overallRating' as text) as numeric)) * 100)"
    end
  end

  def self.get_ages(platform)
    ages = []
    for i in (DefPlayer.where(platform: platform).order('age ASC').first.age..DefPlayer.where(platform: platform).order('age DESC').first.age)
    	ages << {
    		value: i,
    		reference: i
    	}
    end
    ages
  end
end
