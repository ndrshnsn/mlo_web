class ClubFinanceValueToClubFinanceValueCents < ActiveRecord::Migration[7.2]
  def change
    rename_column :club_finances, :value, :value_cents



  end
end
