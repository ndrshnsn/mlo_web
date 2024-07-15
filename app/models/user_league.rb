class UserLeague < ApplicationRecord
  belongs_to :user
  belongs_to :league

  def self.get_fake_accounts(id)
    UserLeague.joins(:user).where("user_leagues.league_id = ? AND users.preferences -> 'fake' = ?", id, "true")
  end
end
