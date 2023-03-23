class League < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  include BadgeUploader::Attachment(:badge)

  has_many :user_leagues, dependent: :destroy
  has_many :users, through: :user_leagues
  has_many :seasons, dependent: :destroy
  has_many :awards, dependent: :destroy
end
