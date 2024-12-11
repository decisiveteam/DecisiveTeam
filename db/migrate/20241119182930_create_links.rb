class CreateLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :links, id: :uuid do |t|
      t.references :tenant, null: false, foreign_key: true, type: :uuid
      t.references :from_linkable, polymorphic: true, null: false, type: :uuid
      t.references :to_linkable, polymorphic: true, null: false, type: :uuid

      t.timestamps
    end
  end
end
