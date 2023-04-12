class DefTeam < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  serialize :platforms, JSON

  has_many :clubs
  belongs_to :def_country

  ## Details
  jsonb_accessor :details,
    wikipediaURL: :string,
    teamName: :string,
    teamAbbr: :string,
    teamFounded: :string,
    teamStadium: :string,
    teamCapacity: :string,
    teamCity: :string

  def self.getTranslation(team)
    translation = []
    if ApplicationController.helpers.i18n_set? "playerdb.teams.#{team.delete(" ")}"
      translation.push(I18n.t("playerdb.teams.#{team.delete(" ")}"), team)
    else
      translation.push(team)
    end
    translation
  end
end
