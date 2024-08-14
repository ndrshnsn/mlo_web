class RenameAwardPrize < ActiveRecord::Migration[7.1]
  def change
    remove_column :awards, :prize
    add_monetize :awards, :prize, currency: { present: false }
  end
end
