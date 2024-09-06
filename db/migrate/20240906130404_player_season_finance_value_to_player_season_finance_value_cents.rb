class PlayerSeasonFinanceValueToPlayerSeasonFinanceValueCents < ActiveRecord::Migration[7.2]
  def change
    rename_column :player_season_finances, :value, :value_cents
  end
end
