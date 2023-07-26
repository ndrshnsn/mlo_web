class AddExtraToUserAcls < ActiveRecord::Migration[7.0]
  def change
    add_column :user_acls, :extra, :string, default: nil
  end
end
