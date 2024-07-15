class DestroyIdentity < ActiveRecord::Migration[7.0]
  def change
    drop_table :identities
  end
end
