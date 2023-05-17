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
  # Include default devise modules. Others available are:
  # :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable#,
        #  :confirmable, :lockable

  has_many :team_members
  has_many :teams, through: :team_members

  def granted_oauth_applications
    Doorkeeper::Application.where(id: self.access_grants.pluck(:oauth_application_id))
  end

  def can_admin_oauth_applications?
    is_admin?
  end

  def get_or_create_api_token(expires_in: nil, scopes: nil)
    application = Doorkeeper::Application.find_by(name: "System")
    token = Doorkeeper::AccessToken.where(
      application_id: application.id,
      resource_owner_id: self.id
    ).first
    if token.nil?
      token = create_api_token(expires_in, scopes)
    end
    token
  end

  def create_api_token(expires_in: nil, scopes: nil)
    application = Doorkeeper::Application.find_by(name: "System")
    token = Doorkeeper::AccessToken.create!(
      application_id: application.id,
      resource_owner_id: self.id,
      expires_in: expires_in || Doorkeeper.configuration.access_token_expires_in,
      scopes: scopes || 'read'
    )
  end
end
