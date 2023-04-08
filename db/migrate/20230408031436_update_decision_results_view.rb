class UpdateDecisionResultsView < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      DROP VIEW decision_results
    SQL
    execute <<-SQL
      CREATE VIEW decision_results AS
        SELECT
          o.decision_id,
          o.id AS option_id,
          o.title AS option_title,
          SUM(a.value) AS approved_yes,
          COUNT(a.value) - SUM(a.value) AS approved_no,
          COUNT(a.value) AS approval_count
        FROM options o
        LEFT JOIN approvals a ON a.option_id = o.id
        GROUP BY o.decision_id, o.id
        ORDER BY approved_yes DESC
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
          a.option_id,
          SUM(a.value) AS approved_yes,
          COUNT(a.value) - SUM(a.value) AS approved_no,
          COUNT(a.value) AS approval_count
        FROM approvals a
        INNER JOIN options o ON a.option_id = o.id
        GROUP BY o.decision_id, a.option_id
        ORDER BY approved_yes DESC
    SQL
  end
end
