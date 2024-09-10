class ChangePlayerSeasonSalaryToMoney < ActiveRecord::Migration[7.2]
  def change
    add_monetize :player_seasons, :salary, currency: { present: false }
  end
end
