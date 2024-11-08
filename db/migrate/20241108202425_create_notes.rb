class CreateNotes < ActiveRecord::Migration[7.0]
  def change
    create_table :notes, id: :uuid do |t|
      t.text :title
      t.text :text
      t.string :truncated_id, null: false, as: 'LEFT(id::text, 8)', stored: true

      t.timestamps
    end
    add_index :notes, :truncated_id, unique: true
  end
end
