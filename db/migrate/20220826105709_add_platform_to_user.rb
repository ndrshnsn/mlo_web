class AddPlatformToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :platform, :string
  end
end
