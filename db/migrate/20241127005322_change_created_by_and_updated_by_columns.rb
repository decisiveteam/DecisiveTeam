class ChangeCreatedByAndUpdatedByColumns < ActiveRecord::Migration[7.0]
  def change
    change_table :notes do |t|
      t.references :created_by, foreign_key: { to_table: :users }, type: :uuid
      t.references :updated_by, foreign_key: { to_table: :users }, type: :uuid
    end

    remove_column :decisions, :created_by_id, :uuid
    change_table :decisions do |t|
      t.references :created_by, foreign_key: { to_table: :users }, type: :uuid
      t.references :updated_by, foreign_key: { to_table: :users }, type: :uuid
    end

    change_table :commitments do |t|
      t.references :created_by, foreign_key: { to_table: :users }, type: :uuid
      t.references :updated_by, foreign_key: { to_table: :users }, type: :uuid
    end
  end
end
