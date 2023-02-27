class RemoveLocaleFromUser < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :preferred_locale
  end
end
