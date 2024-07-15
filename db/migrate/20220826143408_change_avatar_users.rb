class ChangeAvatarUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :gravatar_url
    add_column :users, :avatar_data, :text
  end
end
