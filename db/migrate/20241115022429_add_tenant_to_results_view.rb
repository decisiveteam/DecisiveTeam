class AddTenantToResultsView < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      DROP VIEW decision_results
    SQL
    execute <<-SQL
      CREATE VIEW decision_results AS
        SELECT
          o.tenant_id,
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
        GROUP BY o.tenant_id, o.decision_id, o.id
        ORDER BY approved_yes DESC, stars DESC, random_id DESC
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW decision_results
    SQL
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
end
