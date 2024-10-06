class CreateCommitments < ActiveRecord::Migration[7.0]
  def change
    create_table :commitments, id: :uuid do |t|
      t.text :title
      t.text :description
      t.integer :critical_mass
      t.datetime :deadline
      t.string :truncated_id, null: false, as: 'LEFT(id::text, 8)', stored: true
      t.timestamps
    end
    add_index :commitments, :truncated_id, unique: true
  end
end
