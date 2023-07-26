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
    return Award.where(league_id: league_id, status: true).order(name: :asc)
  end

  def self.get_seasons(league_id)
    return Season.where(league_id: league_id).order(updated_at: :desc)
  end

  def pre_destroy_task
    ## check if admin manages other leagues
    other_leagues = League.where(user_id: user.id)
    if other_leagues.size > 0
      # assign another league as active_league to users preferences
      user.preferences["active_league"] = other_leagues.order("RANDOM()").first.id
      user.save!
    end

    ## remove any fake account from league before removing itself
    users.each{ |u| U.delete if U.preferences["fake"] == true }
  end
end
