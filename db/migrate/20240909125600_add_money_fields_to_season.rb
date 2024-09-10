class AddMoneyFieldsToSeason < ActiveRecord::Migration[7.2]
  def change
    add_monetize :seasons, :club_default_earning, currency: { present: false }
    add_monetize :seasons, :club_max_total_wage, currency: { present: false }
    add_monetize :seasons, :default_mininum_operation, currency: { present: false }
    add_monetize :seasons, :fire_tax_fixed, currency: { present: false }
    add_monetize :seasons, :default_player_earnings_fixed, currency: { present: false }
  end
end
