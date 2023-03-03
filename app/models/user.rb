class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  include ActiveModel::SecurePassword
  extend FriendlyId
  friendly_id :full_name, use: :slugged
  before_create :add_jti

  include AvatarUploader::Attachment(:avatar)

  enum role: [:user, :manager, :admin]

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
    active_league: [:integer, default: nil],
    fake: [:boolean, default: false],
    sp256dh: [:string, default: ""],
    sauth: [:string, default: ""],
    sendpoint: [:string, default: ""]

  ## Associations
  has_many :identities, dependent: :destroy
  has_many :user_leagues, dependent: :destroy
  has_many :leagues, through: :user_leagues
  has_many :notifications, as: :recipient, dependent: :destroy
  has_many :user_seasons
  has_many :seasons, through: :user_seasons
  has_many :clubs, through: :user_seasons
  has_many :club_players, through: :clubs
  #has_many :club_championships, through: :clubs

  ## Devise
  devise :database_authenticatable, :registerable, :confirmable, :trackable,
        :recoverable, :rememberable, :validatable, :timeoutable,
        :omniauthable, omniauth_providers: %i[google_oauth2 twitter2]

  ## Omniauth
  def self.from_omniauth(auth)
    user = find_or_initialize_by(email: auth.info.email)
    user.email = auth.info.email
    user.full_name = auth.info.name
    user.gravatar_url = auth.info.image

    if user.avatar_data.blank?
      user.avatar_data = nil
    end

    user.save
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
    if self.new_record?
      self.role ||= :user
    end
  end

  def self.getClub(user_id, season_id)
    return User.find(user_id).clubs.where(user_seasons: { season_id: season_id } ).first
  end

  def self.getTeamPlayers(user_id, season_id)
    return User.find(user_id).club_players.where(user_seasons:{season_id: season_id}).order_by_position
  end
end
