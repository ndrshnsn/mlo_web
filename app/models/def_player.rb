class DefPlayer < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  has_noticed_notifications

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

  def self.getSeasonInitialSalary(season, player)
    if season.preferences["default_player_earnings"] == "fixed"
      return season.preferences["default_player_earnings"].gsub(/[^\d\.]/, '').to_i
    end

    if season.preferences["default_player_earnings"] == "proportional"
      sMultiplier = "1.0#{player.details["attrs"]["overallRating"].to_i}".to_f
      return ((player.details["attrs"]["overallRating"].to_i * sMultiplier)*100).round(0)
    end
  end
end