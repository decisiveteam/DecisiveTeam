class Page < ActiveRecord::Base
  belongs_to :tenant
  before_validation :set_tenant
  belongs_to :studio
  before_validation :set_studio
  belongs_to :user

  before_save :generate_html
  before_save :set_published_at

  validates :path, presence: true

  def set_tenant
    self.tenant_id ||= Tenant.current_id
  end

  def set_studio
    self.studio_id ||= Studio.current_id
  end

  def generate_html
    self.html = MarkdownRenderer.render(markdown, shift_headers: false, display_references: false)
  end

  def set_published_at
    if published && published_at.nil?
      self.published_at = Time.now
    end
  end

  def full_studio_path
    p = studio.path
    if p
      "#{p}/pages/#{path}"
    else
      "/#{path}"
    end
  end

  def author
    user
  end
end