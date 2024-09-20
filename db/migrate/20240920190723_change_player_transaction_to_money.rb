class ChangePlayerTransactionToMoney < ActiveRecord::Migration[7.2]
  def change
    remove_column :player_transactions, :transfer_rate
    add_monetize :player_transactions, :transfer_rate, currency: { present: false }
  end
end
