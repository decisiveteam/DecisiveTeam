class CreateTenants < ActiveRecord::Migration[7.0]
  def change
    create_table :tenants, id: :uuid do |t|
      t.string :subdomain, null: false
      t.string :name, null: false

      t.timestamps
    end
    add_index :tenants, :subdomain, unique: true
  end
end
