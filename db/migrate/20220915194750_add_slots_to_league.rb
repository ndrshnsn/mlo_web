class AddSlotsToLeague < ActiveRecord::Migration[7.0]
  def change
    add_column :leagues, :slots, :integer, default: 0
  end
end
