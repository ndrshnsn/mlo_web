class AddGsequenceToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :gsequence, :bigint
  end
end
