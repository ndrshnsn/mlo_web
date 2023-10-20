class AddGameSelectionToClubChampionships < ActiveRecord::Migration[7.1]
  def change
    add_column :club_championships, :show_all_games, :boolean, default: false
  end
end
