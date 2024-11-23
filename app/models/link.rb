class Link < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :tenant
  before_validation :set_tenant_id

  belongs_to :from_linkable, polymorphic: true
  belongs_to :to_linkable, polymorphic: true

  def set_tenant_id
    return unless self.tenant_id.nil?
    from_tenant_id = from_linkable.tenant_id
    to_tenant_id = to_linkable.tenant_id
    if from_tenant_id != to_tenant_id
      errors.add(:base, "Cannot link objects from different tenants")
    end
    self.tenant_id = from_tenant_id
  end

  def self.backlink_leaderboard(start_date: nil, end_date: nil, tenant_id: nil, limit: 10)
    tenant_id ||= Tenant.current_id
    if tenant_id.nil?
      raise "Cannot call backlink_leaderboard without tenant_id"
    end
    start_date = Time.current - 100.years if start_date.nil?
    end_date = Time.current if end_date.nil?
    counts = Link.connection.execute(<<-SQL)
      SELECT
        l.to_linkable_id AS id,
        l.to_linkable_type AS type,
        COALESCE(n.title, d.question, c.title) AS title,
        COUNT(*) AS count
      FROM
        links l
      LEFT JOIN
        notes n ON l.to_linkable_type = 'Note' AND l.tenant_id = n.tenant_id AND l.to_linkable_id = n.id
      LEFT JOIN
        decisions d ON l.to_linkable_type = 'Decision' AND l.tenant_id = d.tenant_id AND l.to_linkable_id = d.id
      LEFT JOIN
        commitments c ON l.to_linkable_type = 'Commitment' AND l.tenant_id = c.tenant_id AND l.to_linkable_id = c.id
      WHERE
        l.tenant_id = '#{tenant_id}' AND l.created_at >= '#{start_date}' AND l.created_at <= '#{end_date}'
      GROUP BY
        l.to_linkable_id, l.to_linkable_type, n.title, d.question, c.title
      ORDER BY
        count DESC
      LIMIT
        #{limit}
    SQL
    counts.to_a
  end
end