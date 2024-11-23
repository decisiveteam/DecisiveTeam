class TenantUser < ApplicationRecord
  belongs_to :tenant
  belongs_to :user
  before_create :set_defaults

  def set_defaults
    self.handle ||= user.email
    self.display_name ||= user.name
    self.settings ||= {}
    self.settings['pinned'] ||= []
  end

  def user
    @user ||= super
    @user.tenant_user ||= self
    @user
  end

  def pin_item!(item)
    pin_items!([item])
  end

  def pin_items!(items)
    self.settings['pinned'] += items.map do |item|
      {
        type: item.class.to_s,
        id: item.id
      }
    end
    save!
  end

  def pinned_items
    settings['pinned'].map do |item|
      item['type'].constantize.find_by(id: item['id'])
    end
  end

end
