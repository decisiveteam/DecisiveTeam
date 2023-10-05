class Auth0Controller < ApplicationController
  def callback
    # OmniAuth stores the information returned from Auth0 and the IdP in request.env['omniauth.auth'].
    # In this code, you will pull the raw_info supplied from the id_token and assign it to the session.
    # Refer to https://github.com/auth0/omniauth-auth0/blob/master/EXAMPLES.md#example-of-the-resulting-authentication-hash for complete information on 'omniauth.auth' contents.
    auth_info = request.env['omniauth.auth']
    raw_info = auth_info['extra']['raw_info']
    email = raw_info['email'] || auth_info['info']['email'] || "#{raw_info['sub']}@#{AUTH0_CONFIG['auth0_domain']}"

    # Upsert the user record using the Auth0 ID, and update other fields.
    user = User.find_or_create_by(auth0_id: raw_info['sub']) do |new_user|
      new_user.email = email
      new_user.name = raw_info['name']
      new_user.picture_url = raw_info['picture']
    end
    user.update(
      email: email,
      name: raw_info['name'],
      picture_url: raw_info['picture']
    )

    # Attach the user record to the session.
    session[:user_id] = user.id

    # Forget anonymous participant_uid
    clear_participant_uid_cookie

    redirect_to '/'
  end

  def failure
    # TODO - handle failed authentication -- Show a failure page or redirect
    @error_msg = request.params['message']
  end

  def login
    # TODO
    redirect_to '/'
  end

  def logout
    reset_session
    redirect_to logout_url, allow_other_host: true
  end

  private

  def logout_url
    request_params = {
      returnTo: root_url,
      client_id: AUTH0_CONFIG['auth0_client_id']
    }

    URI::HTTPS.build(host: AUTH0_CONFIG['auth0_domain'], path: '/v2/logout', query: request_params.to_query).to_s
  end
end
