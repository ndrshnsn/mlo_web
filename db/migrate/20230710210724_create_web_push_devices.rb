class CreateWebPushDevices < ActiveRecord::Migration[7.0]
  def change
    create_table :web_push_devices do |t|
      t.references :user, null: false, foreign_key: true
      t.string :endpoint
      t.string :auth_key
      t.string :p256dh_key
      t.string :user_agent
      t.cidr :user_ip

      t.timestamps
    end
  end
end
