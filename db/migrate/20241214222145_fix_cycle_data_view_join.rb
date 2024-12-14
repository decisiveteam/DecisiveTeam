# Fixes join bug in notes view (changes JOIN to LEFT JOIN on note_history_events).
class FixCycleDataViewJoin < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      DROP VIEW cycle_data;
      DROP VIEW cycle_data_notes;
    SQL
    # Notes
    execute <<-SQL
      CREATE VIEW cycle_data_notes AS
        SELECT
          n.tenant_id,
          n.studio_id,
          'Note' AS item_type,
          n.id AS item_id,
          n.title,
          n.created_at,
          n.updated_at,
          n.created_by_id,
          n.updated_by_id,
          n.deadline,
          COUNT(DISTINCT nl.id)::int AS link_count,
          COUNT(DISTINCT nbl.id)::int AS backlink_count,
          COUNT(DISTINCT nhe.user_id)::int AS participant_count,
          NULL::int AS voter_count,
          NULL::int AS option_count
        FROM notes n
        -- BEGIN CHANGE
        LEFT JOIN note_history_events nhe ON n.id = nhe.note_id AND nhe.event_type = 'confirmed_read'
        -- END CHANGE
        LEFT JOIN links nl ON n.id = nl.from_linkable_id AND nl.from_linkable_type = 'Note'
        LEFT JOIN links nbl ON n.id = nbl.to_linkable_id AND nbl.to_linkable_type = 'Note'
        GROUP BY n.tenant_id, n.studio_id, n.id
        ORDER BY n.tenant_id, n.studio_id, n.created_at DESC
    SQL
    # Combined data
    execute <<-SQL
      CREATE VIEW cycle_data AS
        SELECT *
        FROM cycle_data_notes n
        UNION ALL
        SELECT *
        FROM cycle_data_decisions
        UNION ALL
        SELECT *
        FROM cycle_data_commitments
        ORDER BY tenant_id, studio_id, created_at DESC
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW cycle_data;
      DROP VIEW cycle_data_notes;
    SQL
    # Notes
    execute <<-SQL
      CREATE VIEW cycle_data_notes AS
        SELECT
          n.tenant_id,
          n.studio_id,
          'Note' AS item_type,
          n.id AS item_id,
          n.title,
          n.created_at,
          n.updated_at,
          n.created_by_id,
          n.updated_by_id,
          n.deadline,
          COUNT(DISTINCT nl.id)::int AS link_count,
          COUNT(DISTINCT nbl.id)::int AS backlink_count,
          COUNT(DISTINCT nhe.user_id)::int AS participant_count,
          NULL::int AS voter_count,
          NULL::int AS option_count
        FROM notes n
        JOIN note_history_events nhe ON n.id = nhe.note_id AND nhe.event_type = 'confirmed_read'
        LEFT JOIN links nl ON n.id = nl.from_linkable_id AND nl.from_linkable_type = 'Note'
        LEFT JOIN links nbl ON n.id = nbl.to_linkable_id AND nbl.to_linkable_type = 'Note'
        GROUP BY n.tenant_id, n.studio_id, n.id
        ORDER BY n.tenant_id, n.studio_id, n.created_at DESC
    SQL
    # Combined data
    execute <<-SQL
      CREATE VIEW cycle_data AS
        SELECT *
        FROM cycle_data_notes n
        UNION ALL
        SELECT *
        FROM cycle_data_decisions
        UNION ALL
        SELECT *
        FROM cycle_data_commitments
        ORDER BY tenant_id, studio_id, created_at DESC
    SQL
  end
end
