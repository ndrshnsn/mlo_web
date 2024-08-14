class Award < ApplicationRecord
  belongs_to :league
  has_many :championhip_awards
  has_many :season_awards

  include TrophyUploader::Attachment(:trophy)

  monetize :prize_cents, as: :prize
end
