class ChangeClubFinanceBalanceToMonetize < ActiveRecord::Migration[7.2]
  def change
    remove_column :club_finances, :balance
    add_monetize :club_finances, :balance, currency: { present: false }
  end
end
