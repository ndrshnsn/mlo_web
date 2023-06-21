class CreateUserAcls < ActiveRecord::Migration[7.0]
  def change
    create_table :user_acls do |t|
      t.references :user, null: false, foreign_key: true
      t.string :role
      t.boolean :permitted

      t.timestamps
    end

    add_index :user_acls, :role
  end
end
