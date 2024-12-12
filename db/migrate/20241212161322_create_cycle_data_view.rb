class CreateCycleDataView < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      DROP VIEW IF EXISTS cycle_data;
      DROP VIEW IF EXISTS cycle_data_notes;
      DROP VIEW IF EXISTS cycle_data_decisions;
      DROP VIEW IF EXISTS cycle_data_commitments;
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
    # Decisions
    execute <<-SQL
      CREATE VIEW cycle_data_decisions AS
        SELECT
          d.tenant_id,
          d.studio_id,
          'Decision' AS item_type,
          d.id AS item_id,
          d.question AS title,
          d.created_at,
          d.updated_at,
          d.created_by_id,
          d.updated_by_id,
          d.deadline,
          COUNT(DISTINCT dl.id)::int AS link_count,
          COUNT(DISTINCT dbl.id)::int AS backlink_count,
          COUNT(DISTINCT a.decision_participant_id)::int AS participant_count,
          COUNT(DISTINCT a.decision_participant_id)::int AS voter_count,
          COUNT(DISTINCT o.id)::int AS option_count
        FROM decisions d
        LEFT JOIN approvals a ON d.id = a.decision_id
        LEFT JOIN options o ON d.id = o.decision_id
        LEFT JOIN links dl ON d.id = dl.from_linkable_id AND dl.from_linkable_type = 'Decision'
        LEFT JOIN links dbl ON d.id = dbl.to_linkable_id AND dbl.to_linkable_type = 'Decision'
        GROUP BY d.tenant_id, d.studio_id, d.id
        ORDER BY d.tenant_id, d.studio_id, d.created_at DESC
    SQL
    # Commitments
    execute <<-SQL
      CREATE VIEW cycle_data_commitments AS
        SELECT
          c.tenant_id,
          c.studio_id,
          'Commitment' AS item_type,
          c.id AS item_id,
          c.title,
          c.created_at,
          c.updated_at,
          c.created_by_id,
          c.updated_by_id,
          c.deadline,
          COUNT(DISTINCT cl.id)::int AS link_count,
          COUNT(DISTINCT cbl.id)::int AS backlink_count,
          COUNT(DISTINCT p.user_id)::int AS participant_count,
          NULL::int AS voter_count,
          NULL::int AS option_count
        FROM commitments c
        LEFT JOIN commitment_participants p ON c.id = p.commitment_id
        LEFT JOIN links cl ON c.id = cl.from_linkable_id AND cl.from_linkable_type = 'Commitment'
        LEFT JOIN links cbl ON c.id = cbl.to_linkable_id AND cbl.to_linkable_type = 'Commitment'
        GROUP BY c.tenant_id, c.studio_id, c.id
        ORDER BY c.tenant_id, c.studio_id, c.created_at DESC
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
      DROP VIEW cycle_data_decisions;
      DROP VIEW cycle_data_commitments;
    SQL
  end
end
