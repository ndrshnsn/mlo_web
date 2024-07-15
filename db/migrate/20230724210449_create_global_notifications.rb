class CreateGlobalNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :global_notifications do |t|
      t.references :league, null: false, foreign_key: true
      t.string :title
      t.text :body
      t.jsonb :params

      t.timestamps
    end

    add_index :global_notifications, :params, using: :gin
  end
end
