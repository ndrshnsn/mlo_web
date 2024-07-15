class AddAuditableId < ActiveRecord::Migration[7.1]
  def change
    add_column :audits, :auditable_id, :uuid, default: "gen_random_uuid()", null: false
  end
end
