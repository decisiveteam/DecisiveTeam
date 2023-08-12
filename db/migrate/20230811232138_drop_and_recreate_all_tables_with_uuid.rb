class DropAndRecreateAllTablesWithUuid < ActiveRecord::Migration[7.0]
  def up
    # Drop view
    execute <<-SQL
      DROP VIEW decision_results
    SQL
    # Drop tables
    drop_table :approvals
    drop_table :options
    drop_table :decision_participants
    drop_table :decisions

    # Recreate tables with uuid primary keys
    create_table :decisions, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.text :question
      t.text :description
      t.jsonb :other_attributes
      t.timestamps
    end

    create_table :decision_participants, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :decision, type: :uuid, foreign_key: true
      t.string :name
      t.timestamps
    end

    create_table :options, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :decision, type: :uuid, foreign_key: true
      t.references :decision_participant, type: :uuid, foreign_key: true
      t.text :title, null: false
      t.text :description
      t.jsonb :other_attributes
      t.integer :random_id, null: false, default: -> { 'floor(random() * 1000000000)::integer' }
      t.timestamps
    end

    create_table :approvals, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :decision, type: :uuid, foreign_key: true
      t.references :decision_participant, type: :uuid, foreign_key: true
      t.references :option, type: :uuid, foreign_key: true
      t.integer :value, null: false
      t.integer :stars, default: 0
      t.timestamps
    end

    add_index :options, [:decision_id, :title], unique: true
    add_index :approvals, [:option_id, :decision_participant_id], unique: true

    # Recreate view
    execute <<-SQL
      CREATE VIEW decision_results AS
        SELECT
          o.decision_id,
          o.id AS option_id,
          o.title AS option_title,
          COALESCE(SUM(a.value), 0) AS approved_yes,
          COUNT(a.value) - COALESCE(SUM(a.value), 0) AS approved_no,
          COUNT(a.value) AS approval_count,
          COALESCE(SUM(a.stars), 0) AS stars,
          o.random_id AS random_id
        FROM options o
        LEFT JOIN approvals a ON a.option_id = o.id
        GROUP BY o.decision_id, o.id
        ORDER BY approved_yes DESC, stars DESC, random_id DESC
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
