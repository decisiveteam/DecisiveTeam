class DropStudioTrusteesAddAsColumn < ActiveRecord::Migration[7.0]
  def up
    add_column :studios, :trustee_user_id, :uuid, null: true, foreign_key: { to_table: :users }
    StudioTrustee.all.each do |studio_trustee|
      studio_trustee.studio.update!(trustee_user_id: studio_trustee.trustee_user_id)
    end
    drop_table :studio_trustees
  end

  def down
    create_table :studio_trustees, id: :uuid do |t|
      t.references :tenant, null: false, foreign_key: true, type: :uuid
      t.references :studio, null: false, foreign_key: true, type: :uuid
      t.references :trustee_user, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.jsonb :settings, default: {}
      t.timestamps
    end
    add_index :studio_trustees, [:tenant_id, :studio_id, :trustee_user_id], unique: true, name: 'studio_trustees_unique_index'
    Studio.all.each do |studio|
      if studio.trustee_user_id
        StudioTrustee.create!(tenant_id: studio.tenant_id, studio_id: studio.id, trustee_user_id: studio.trustee_user_id)
      end
    end
    remove_column :studios, :trustee_user_id
  end
end
