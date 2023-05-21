class User < ApplicationRecord
  has_many :oauth_applications,
           class_name: 'Doorkeeper::Application',
           as: :owner
  has_many :access_grants,
           class_name: "Doorkeeper::AccessGrant",
           foreign_key: :resource_owner_id,
           dependent: :delete_all
  has_many :access_tokens,
           class_name: "Doorkeeper::AccessToken",
           foreign_key: :resource_owner_id,
           dependent: :delete_all
  has_many :team_invites, foreign_key: 'created_by_id'
  has_many :decision_invites, foreign_key: 'created_by_id'
  has_many :decisions, foreign_key: 'created_by_id'
  has_many :decision_participants, as: :entity
  has_many :options, through: :decision_participants
  has_many :approvals, through: :decision_participants
  # Include default devise modules. Others available are:
  # :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable#,
        #  :confirmable, :lockable

  has_many :team_members
  has_many :teams, through: :team_members

  def name
    display_name || username || email
  end

  def granted_oauth_applications
    Doorkeeper::Application.where(id: self.access_grants.pluck(:oauth_application_id))
  end

  def can_admin_oauth_applications?
    is_admin?
  end

  def create_api_token(expires_in: nil, scopes: nil)
    application = SystemResourceService.system_oauth_application
    token = Doorkeeper::AccessToken.create!(
      application_id: application.id,
      resource_owner_id: self.id,
      expires_in: expires_in || Doorkeeper.configuration.access_token_expires_in,
      scopes: scopes || 'read'
    )
  end
end
