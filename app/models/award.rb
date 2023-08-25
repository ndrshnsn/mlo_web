class Award < ApplicationRecord
  belongs_to :league
  has_many :championhip_awards
  has_many :season_awards

  include TrophyUploader::Attachment(:trophy)
  include Hashid::Rails
end
