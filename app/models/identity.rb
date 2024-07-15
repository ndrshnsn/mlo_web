class Identity < ApplicationRecord
  belongs_to :user, optional: true

  def self.find_with_omniauth(auth)
    find_by(uid: auth[:uid], provider: auth[:provider])
  end

  def self.create_with_omniauth(auth, user = nil)
    if user
      create(user_id: user, uid: auth[:uid], gravatar_url: auth[:gravatar_url], provider: auth[:provider])
    else
      create(uid: auth[:uid], gravatar_url: auth[:gravatar_url], provider: auth[:provider])
    end
  end
end
