class ChangeSourceIdToUuid < ActiveRecord::Migration[7.1]
  def change
    remove_column :club_finances, :source_id 
    add_column :club_finances, :source_id, :string, null: true
  end
end
