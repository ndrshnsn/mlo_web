class AddLeagueToUserAcl < ActiveRecord::Migration[7.0]
  def change
    add_reference :user_acls, :league, null: false, foreign_key: true
  end
end
