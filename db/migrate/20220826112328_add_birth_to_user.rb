class AddBirthToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :birth, :date
  end
end
