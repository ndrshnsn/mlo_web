class CreateIdentities < ActiveRecord::Migration[7.0]
  def change
    create_table :identities do |t|
      t.string :provider
      t.string :uid
      t.references :user, null: true, foreign_key: true
      t.string :gravatar_url

      t.timestamps
    end
  end
end
