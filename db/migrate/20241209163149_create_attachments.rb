class CreateAttachments < ActiveRecord::Migration[7.0]
  def change
    create_table :attachments, id: :uuid do |t|
      t.references :tenant, type: :uuid, null: false, foreign_key: true
      t.references :studio, type: :uuid, null: false, foreign_key: true
      t.references :attachable, polymorphic: true, null: false, type: :uuid
      t.string :name, null: false
      t.string :content_type, null: false
      t.bigint :byte_size, null: false
      t.references :created_by, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.references :updated_by, type: :uuid, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :attachments, [:tenant_id, :studio_id, :attachable_id, :name], unique: true, name: 'index_attachments_on_tenant_studio_attachable_name'
  end
end
