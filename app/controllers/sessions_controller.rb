# NOTE - We have to do some redirecting to use the same OAuth providers across different tenant subdomains.
# The way we do this is by having a single designated auth subdomain that is registered with OAuth providers,
# then all tenants redirect to that one auth subdomain to authenticate, and once authenticated, the user is
# redirected back to the original tenant subdomain with a token cookie that can be used to log in with the tenant.
class SessionsController < ApplicationController

  # <login>
  # Step 1: direct user to auth domain login page where they can authenticate with OAuth provider
  def new
    if current_user && request.subdomain != auth_subdomain
      # user is already logged in. nothing to do.
      redirect_to root_path
    elsif current_user && request.subdomain == auth_subdomain
      # The auth subdomain should never retain a user session.
      session.delete(:user_id)
      raise 'Unexpected error. User should not be logged in on the auth domain.'
    elsif request.subdomain == auth_subdomain
      # user is not logged in and is currently on the auth domain
      # so we show the login page and display the original tenant subdomain
      @page_title = 'Login | Harmonic Team'
      @original_tenant = Tenant.find_by(subdomain: cookies[:redirect_to_subdomain])
      # TODO - handle case where tenant is not found
      @redirect_to_resource = cookies[:redirect_to_resource]
      @studio_invite_code = cookies[:studio_invite_code]
    else
      # user is on the tenant subdomain and is not logged in
      # so we redirect them to the auth domain
      redirect_to_auth_domain
    end
  end

  # Step 2: OAuth provider redirects back to auth domain callback URL
  def oauth_callback
    # This is the callback from the OAuth provider to the auth domain.
    return redirect_to root_path if request.subdomain != auth_subdomain
    identity = OauthIdentity.find_or_create_from_auth(request.env['omniauth.auth'])
    session[:user_id] = identity.user.id
    redirect_to '/login/return'
  end

  # Step 3: redirect back to original tenant subdomain with a token cookie
  def return
    # This is the final step on the auth subdomain after the user has authenticated with the OAuth provider.
    if current_user && request.subdomain == auth_subdomain
      # Expected scenario
      redirect_to_original_tenant
    else
      # Unexpected scenario. Start over.
      redirect_to '/login'
    end
  end

  # Step 4: process the token cookie and redirect to the resource path or root path
  def internal_callback
    # This is the callback to the original tenant from the auth domain, completing the authentication process.
    if cookies[:token] && request.subdomain != auth_subdomain
      # Expected scenario
      process_token_and_redirect_to_resource_or_root
    else
      # Unexpected scenario. Delete cookie and start over.
      delete_token_cookie if cookies[:token]
      redirect_to '/login'
    end
  end
  # </login>

  # <logout>
  def destroy
    session.delete(:user_id)
    session.delete(:impersonating)
    # Cookie deletion is not technically necessary,
    # but it guarantees that the user session does not get into a weird state.
    delete_token_cookie
    delete_redirect_to_subdomain_cookie

    redirect_to '/logout-success'
  end

  def logout_success
    if current_user
      # user is still logged in
      redirect_to root_path
    end
  end
  # </logout>

  private

  def redirect_to_auth_domain
    raise 'Unexpected error. Wrong subdomain.' if request.subdomain == auth_subdomain
    set_shared_domain_cookie(:redirect_to_subdomain, request.subdomain)
    if params[:redirect_to_resource]
      resource = LinkParser.parse_path(params[:redirect_to_resource])
      set_shared_domain_cookie(:redirect_to_resource, resource.path) if resource && resource.tenant_id == current_tenant.id
    elsif params[:code]
      set_shared_domain_cookie(:studio_invite_code, params[:code])
    end
    redirect_to auth_domain_login_url,
                allow_other_host: true
  end

  def tenant_domain_callback_url(tenant)
    "https://#{tenant.subdomain}.#{ENV['HOSTNAME']}/login/callback"
  end

  def redirect_to_original_tenant
    raise 'Unexpected error. Wrong subdomain.' if request.subdomain != auth_subdomain
    subdomain = cookies[:redirect_to_subdomain]
    raise 'Unexpected error. Subdomain required.' unless subdomain
    delete_redirect_to_subdomain_cookie
    tenant = Tenant.find_by(subdomain: subdomain)
    # TODO check if user is allowed to access this tenant
    return redirect_to root_path unless tenant && current_user
    token = encrypt_token(tenant.id, current_user.id)
    set_shared_domain_cookie(:token, token)
    session.delete(:user_id) # auth subdomain should never retain a user session
    url = tenant_domain_callback_url(tenant)
    redirect_to url, allow_other_host: true
  end

  def process_token_and_redirect_to_resource_or_root
    # user is returning from auth domain after authenticating
    raise 'Unexpected error. Token required.' unless cookies[:token]
    raise 'Unexpected subdomain.' if cookies[:redirect_to_subdomain]
    raise 'Unexpected error. Subdomain mismatch.' if request.subdomain == auth_subdomain
    tenant_id, user_id = decrypt_token(cookies[:token])
    delete_token_cookie
    tenant = Tenant.find(tenant_id)
    if tenant && tenant.subdomain != request.subdomain
      # user is trying to access a different tenant than the one they authenticated with.
      # This should not happen, so we raise an error.
      raise 'Unexpected error. Tenant mismatch.'
    end
    user = User.find(user_id)
    tenant_user = tenant.tenant_users.find_by(user: user)
    if tenant_user
      session[:user_id] = user.id
    else
      # user is not allowed to access this tenant
      # TODO - handle this case more gracefully
      raise 'Unexpected error. User not allowed to access tenant.'
    end
    redirect_to_resource_or_invite_or_root
  end

  def redirect_to_resource_or_invite_or_root
    if cookies[:redirect_to_resource]
      redirect_to_resource_if_allowed
    elsif cookies[:studio_invite_code]
      redirect_to_invite_if_allowed
    else
      redirect_to root_path
    end
  end

  def redirect_to_resource_if_allowed
    resource_path = cookies[:redirect_to_resource]
    delete_redirect_to_resource_cookie
    resource = LinkParser.parse_path(resource_path)
    if resource && resource.tenant_id == current_tenant.id
      redirect_to resource.path
    else
      redirect_to root_path
    end
  end

  def redirect_to_invite_if_allowed
    invite = StudioInvite.find_by(code: cookies[:studio_invite_code])
    delete_studio_invite_cookie
    if invite && invite.studio.tenant_id == current_tenant.id
      current_user.accept_invite!(invite)
      redirect_to invite.studio.path
    else
      redirect_to root_path
    end
  end

  def encrypt_token(tenant_id, user_id)
    timestamp = Time.now.to_i
    token = encryptor.encrypt_and_sign("#{tenant_id}:#{user_id}:#{timestamp}")
  end

  def decrypt_token(token)
    tenant_id, user_id, timestamp = encryptor.decrypt_and_verify(token).split(':')
    # Redirects happen immediately after authentication,
    # so 30 seconds should be more than enough time for the token to be processed.
    raise 'Token expired' if Time.now.to_i - timestamp.to_i > 30.seconds
    [tenant_id, user_id]
  end

  def set_shared_domain_cookie(key, value)
    cookies[key] = { value: value, domain: ".#{ENV['HOSTNAME']}" }
  end

  def delete_shared_domain_cookie(key)
    cookies.delete(key, domain: ".#{ENV['HOSTNAME']}")
  end

  def delete_token_cookie
    delete_shared_domain_cookie(:token)
  end

  def delete_redirect_to_subdomain_cookie
    delete_shared_domain_cookie(:redirect_to_subdomain)
  end

  def delete_redirect_to_resource_cookie
    delete_shared_domain_cookie(:redirect_to_resource)
  end

  def delete_studio_invite_cookie
    delete_shared_domain_cookie(:studio_invite_code)
  end

end