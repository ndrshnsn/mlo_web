class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  include ActiveModel::SecurePassword
  extend FriendlyId
  friendly_id :full_name, use: :slugged
  before_create :add_jti

  include AvatarUploader::Attachment(:avatar)

  enum role: {user: 0, manager: 1, admin: 2}

  ## Settings
  jsonb_accessor :preferences,
    locale: [:string, default: ""],
    country: [:string, default: ""],
    city: [:string, default: ""],
    theme: [:string, default: ""],
    twitter: [:string, default: ""],
    facebook: [:string, default: ""],
    instagram: [:string, default: ""],
    request: [:boolean, default: false],
    active_league: [:string, default: nil],
    fake: [:boolean, default: false]

  ## Associations
  has_many :user_acls, dependent: :destroy
  has_many :identities, dependent: :destroy
  has_many :user_leagues, dependent: :destroy
  has_many :leagues, through: :user_leagues
  has_many :notifications, as: :recipient, dependent: :destroy
  has_many :web_push_devices, dependent: :destroy
  has_many :user_seasons
  has_many :seasons, through: :user_seasons
  has_many :clubs, through: :user_seasons
  has_many :club_players, through: :clubs
  has_many :club_championships, through: :clubs

  ## Devise
  devise :database_authenticatable, :registerable, :confirmable, :trackable,
    :recoverable, :rememberable, :validatable, :timeoutable,
    :omniauthable, omniauth_providers: %i[google_oauth2 twitter github]

  ## Omniauth
  def self.from_omniauth(auth)
    user = User.find_by(email: auth.info.email)
    # user.email = auth.info.email
    # user.full_name = auth.info.name
    # user.avatar_data = nil if user.avatar_data.blank?
    # user.save!
    user
  end

  def add_jti
    self.jti ||= SecureRandom.uuid
  end

  # Devise _ Doorkeeper
  def self.authenticate(email, password)
    user = User.find_for_authentication(email: email)
    user&.valid_password?(password) ? user : nil
  end

  ## Default Role
  after_initialize do
    self.role ||= :user if new_record?
  end

  def self.getClub(user_id, season_id)
    User.find(user_id).clubs.where(user_seasons: {season_id: season_id}).first
  end

  def self.getTeamPlayers(user_id, season_id)
    season = Season.find(season_id)
    User.find(user_id).club_players.includes(:player_season).where(user_seasons: {season_id: season.id}).order_by_position(season.preferences["raffle_platform"])
  end
end
