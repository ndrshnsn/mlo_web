class League < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  include BadgeUploader::Attachment(:badge)
  audited

  belongs_to :user
  has_many :user_leagues, dependent: :destroy
  has_many :user_acls, dependent: :destroy
  has_many :users, through: :user_leagues
  has_many :seasons, dependent: :destroy
  has_many :awards, dependent: :destroy
  has_many :global_notifications, dependent: :destroy
  #has_many :activities, as: :trackable, class_name: 'PublicActivity::Activity', dependent: :destroy

  before_destroy :pre_destroy_task, prepend: true

  private

  def self.get_awards(league_id)
    Award.where(league_id: league_id, status: true).order(name: :asc)
  end

  def self.get_seasons(league_id)
    Season.where(league_id: league_id).order(updated_at: :desc)
  end

  def pre_destroy_task
    other_leagues = League.where(user_id: user.id)
    if other_leagues.size > 0
      user.preferences["active_league"] = other_leagues.order("RANDOM()").first.id
      user.save!
    end
    users.each{ |user| user.delete if user.preferences["fake"] == true }
  end
end
