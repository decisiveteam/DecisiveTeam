class OauthIdentity < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :user

  def self.find_or_create_from_auth(auth)
    identity = find_or_initialize_by(
      provider: auth.provider,
      uid: auth.uid
    )

    # If identity exists but isn't linked, link it to existing user with same email
    if identity.new_record? && auth.info.email
      user = User.find_by(email: auth.info.email)
    end

    # Create new user if needed
    user ||= identity.user || User.create!(
      email: auth.info.email,
      name: auth.info.name,
      image_url: auth.info.image,
    )

    # Link identity to user
    identity.update!(
      user: user,
      last_sign_in_at: Time.current,
      url: url_from_auth(auth),
      username: auth.info.nickname,
      image_url: auth.info.image,
      auth_data: auth
    )

    identity
  end

  private

  def self.url_from_auth(auth)
    case auth.provider
    when 'github'
      auth.info.urls.GitHub
    end
  end
end