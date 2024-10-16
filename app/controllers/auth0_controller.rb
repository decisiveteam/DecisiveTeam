class Auth0Controller < ApplicationController
  def callback
    # OmniAuth stores the information returned from Auth0 and the IdP in request.env['omniauth.auth'].
    # In this code, you will pull the raw_info supplied from the id_token and assign it to the session.
    # Refer to https://github.com/auth0/omniauth-auth0/blob/master/EXAMPLES.md#example-of-the-resulting-authentication-hash for complete information on 'omniauth.auth' contents.
    auth_info = request.env['omniauth.auth']
    raw_info = auth_info['extra']['raw_info']
    email = raw_info['email'] ||
            auth_info['info']['email'] ||
            (is_email?(raw_info['name']) ? raw_info['name'] : nil) ||
            "#{raw_info['sub']}@#{AUTH0_CONFIG['auth0_domain']}"

    # Upsert the user record using the Auth0 ID, and update other fields.
    user = User.find_or_create_by(auth0_id: raw_info['sub']) do |new_user|
      new_user.email = email
      new_user.name = raw_info['name']
      new_user.picture_url = raw_info['picture']
    end
    user.update(
      email: email,
      name: user.name || raw_info['name'],
      picture_url: raw_info['picture']
    )

    # Attach the user record to the session.
    session[:user_id] = user.id

    if session[:encrypted_participant_id]
      # In this case, the user was prompted to login from a decision page,
      # so we need to update the participant record with the user and redirect back to the decision page.
      begin
        participant_id = decrypt(session[:encrypted_participant_id])
        participant = DecisionParticipant.find_by(id: participant_id)
      end
      if participant
        decision = participant.decision
        decision_path = decision.path
        participant_has_user = participant.user.present?
        user_has_participant = decision.participants.where(user: user).first.present?
        if participant_has_user && user_has_participant && participant.user == user
          # noop
        elsif participant_has_user && participant.user != user
          # Unlikely scenario. User is trying to log in as someone else maybe? or might have multiple logins?
          Rails.logger.info("User #{user.id} is trying to login as #{participant.user.id} for decision #{decision.id}")
        elsif !participant_has_user && user_has_participant
          participant.destroy unless participant.approvals.any?
        elsif !participant_has_user && !user_has_participant
          # Common case
          participant.update(user: user)
        end
      end
      clear_participant_uid_cookie
      session.delete(:encrypted_participant_id)
    else
      # Forget anonymous participant_uid
      clear_participant_uid_cookie
    end

    redirect_to decision_path || '/'
  end

  def failure
    # TODO - handle failed authentication -- Show a failure page or redirect
    @error_msg = request.params['message']
  end

  def login
    if current_user
      redirect_to '/'
    else
      redirect_to login_url, allow_other_host: true
    end
  end

  def logout
    reset_session
    redirect_to logout_url, allow_other_host: true
  end

  private

  def login_url
    request_params = {
      client_id: AUTH0_CONFIG['auth0_client_id'],
      response_type: 'code',
      redirect_uri: auth0_callback_url,
    }
    URI::HTTPS.build(host: AUTH0_CONFIG['auth0_domain'], path: '/authorize', query: request_params.to_query).to_s
  end

  def auth0_callback_url
    request.protocol + request.host_with_port + '/auth/auth0/callback'
  end

  def logout_url
    request_params = {
      returnTo: root_url,
      client_id: AUTH0_CONFIG['auth0_client_id']
    }

    URI::HTTPS.build(host: AUTH0_CONFIG['auth0_domain'], path: '/v2/logout', query: request_params.to_query).to_s
  end

  def is_email?(str)
    return false unless str.is_a?(String)
    str.match?(URI::MailTo::EMAIL_REGEXP)
  end
end
