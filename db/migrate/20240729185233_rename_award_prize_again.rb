class RenameAwardPrizeAgain < ActiveRecord::Migration[7.1]
  def change
    remove_column :awards, :prize_cents
    remove_column :awards, :prize_currency
    add_monetize :awards, :prize, currency: { present: false }
  end
end
