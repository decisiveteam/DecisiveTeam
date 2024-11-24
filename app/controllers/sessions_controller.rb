class SessionsController < ApplicationController
  # NOTE - We have to do some redirecting to use the same OAuth providers across different tenant subdomains.
  # The way we do this is by having a single designated auth subdomain that is registered with OAuth providers,
  # then all tenants redirect to that one auth subdomain to authenticate, and once authenticated, the user is
  # redirected back to the original tenant subdomain with a token cookie that can be used to log in with the tenant.
  def new
    @page_title = 'Login | Harmonic Team'
    scenarios = {
      auth_subdomain_and_not_logged_in_and_has_redirect: request.subdomain == auth_subdomain && current_user.nil? && cookies[:redirect_to_subdomain],
      auth_subdomain_and_not_logged_in_and_no_redirect: request.subdomain == auth_subdomain && current_user.nil? && cookies[:redirect_to_subdomain].nil?,
      auth_subdomain_and_logged_in_and_has_redirect: request.subdomain == auth_subdomain && current_user && cookies[:redirect_to_subdomain],
      auth_subdomain_and_logged_in_and_no_redirect: request.subdomain == auth_subdomain && current_user && cookies[:redirect_to_subdomain].nil?,
      not_auth_subdomain_and_not_logged_in_and_no_token: request.subdomain != auth_subdomain && current_user.nil? && cookies[:token].nil?,
      not_auth_subdomain_and_not_logged_in_and_has_token: request.subdomain != auth_subdomain && current_user.nil? && cookies[:token],
      not_auth_subdomain_and_logged_in_and_has_redirect_to_subdomain: request.subdomain != auth_subdomain && current_user && cookies[:redirect_to_subdomain],
      not_auth_subdomain_and_logged_in_and_has_redirect_to_resource: request.subdomain != auth_subdomain && current_user && !cookies[:redirect_to_subdomain] && cookies[:redirect_to_resource],
      not_auth_subdomain_and_logged_in_without_redirect: request.subdomain != auth_subdomain && current_user && cookies[:redirect_to_subdomain].nil?
    }
    if scenarios[:auth_subdomain_and_not_logged_in_and_has_redirect]
      # user is not logged in and is currently on the auth domain
      # so we show the login page and display the original tenant subdomain
      @current_tenant = Tenant.find_by(subdomain: cookies[:redirect_to_subdomain])
    elsif scenarios[:auth_subdomain_and_not_logged_in_and_no_redirect]
      # user is on the auth domain but we don't have a redirect cookie.
      # Unlikely but possible. We redirect them to the primary subdomain.
      # Maybe we should show an error page instead?
      redirect_to "https://#{ENV['PRIMARY_SUBDOMAIN']}.#{ENV['HOSTNAME']}",
                  allow_other_host: true
    elsif scenarios[:auth_subdomain_and_logged_in_and_has_redirect]
      # user has completed authentication and can now return to the original tenant
      redirect_to_original_tenant
    elsif scenarios[:auth_subdomain_and_logged_in_and_no_redirect]
      # This should not happen. Ambiguous state.
      raise 'Unexpected error. Redirect cookie required.'
    elsif scenarios[:not_auth_subdomain_and_not_logged_in_and_no_token]
      # user needs to authenticate
      redirect_to_auth_domain
    elsif scenarios[:not_auth_subdomain_and_not_logged_in_and_has_token]
      # This should not happen because internal_callback should have processed the token and redirected to the resource or root.
      delete_token_cookie
      raise 'Unexpected error. Redirect required.'
    elsif scenarios[:not_auth_subdomain_and_logged_in_and_has_redirect_to_subdomain]
      # This should not happen because process_token_and_redirect_to_resource_or_root should have deleted the redirect cookies already.
      if cookies[:redirect_to_subdomain] == request.subdomain
        # TODO check if user is allowed to access this tenant
        delete_redirect_to_subdomain_cookie
        redirect_to_resource_or_root
      else
        raise 'Unexpected redirect'
      end
    elsif scenarios[:not_auth_subdomain_and_logged_in_and_has_redirect_to_resource]
      # This should not happen because process_token_and_redirect_to_resource_or_root should have deleted the redirect cookies already.
      # But maybe this can happen if the user is logged into multiple tenants at the same time?
      redirect_to_resource
    elsif scenarios[:not_auth_subdomain_and_logged_in_without_redirect]
      redirect_to root_path
    end
  end

  def create
    # This is the callback from the OAuth provider and should only go to the auth domain.
    return redirect_to root_path if request.subdomain != auth_subdomain
    identity = OauthIdentity.find_or_create_from_auth(request.env['omniauth.auth'])
    session[:user_id] = identity.user.id # User id is only stored temporarily on the auth domain
    redirect_to '/login' # redirect to the login action to handle the remaining logic when the user is authenticated
  end

  def internal_callback
    # This is the callback from the auth domain to the original tenant.
    process_token_and_redirect_to_resource_or_root
  end


  def destroy
    session.delete(:user_id)
    # Cookie deletion is not technically necessary,
    # but it guarantees that the user session does not get into a weird state.
    delete_token_cookie
    delete_redirect_to_subdomain_cookie

    redirect_to '/logout-success'
  end

  def logout_success
    # ??? TODO revisit this
    # This page is shown after a user logs out
    # so that they are not immediately logged back in by the auth domain.
    if current_user
      # user is still logged in
      redirect_to root_path
    end
  end

  private

  def redirect_to_auth_domain
    # TODO assert assumptions
    set_shared_domain_cookie(:redirect_to_subdomain, request.subdomain)
    if params[:redirect_to_resource] && resource = LinkParser.parse_path(params[:redirect_to_resource])
      set_shared_domain_cookie(:redirect_to_resource, resource.path) if resource.tenant_id == current_tenant.id
    end
    redirect_to auth_domain_login_url,
                allow_other_host: true
  end

  def auth_subdomain
    ENV['AUTH_SUBDOMAIN']
  end

  def auth_domain_login_url
    "https://#{auth_subdomain}.#{ENV['HOSTNAME']}/login"
  end

  def redirect_to_original_tenant
    # TODO assert assumptions
    subdomain = cookies[:redirect_to_subdomain]
    raise 'Unexpected error. Subdomain required.' unless subdomain
    delete_redirect_to_subdomain_cookie
    tenant = Tenant.find_by(subdomain: subdomain)
    # TODO check if user is allowed to access this tenant
    return redirect_to root_path unless tenant && current_user
    url = "https://#{tenant.subdomain}.#{ENV['HOSTNAME']}/login/callback"
    token = encrypt_token(tenant.id, current_user.id)
    set_shared_domain_cookie(:token, token)
    session.delete(:user_id) # auth domain must not retain user session
    redirect_to url, allow_other_host: true
  end

  def process_token_and_redirect_to_resource_or_root
    # user is returning from auth domain after authenticating
    assumptions = cookies[:token] && !cookies[:redirect_to_subdomain] && request.subdomain != auth_subdomain
    raise 'Unexpected error. Token required.' unless assumptions
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
    redirect_to_resource_or_root
  end

  def redirect_to_resource_or_root
    if cookies[:redirect_to_resource]
      redirect_to_resource_if_allowed
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

  def encrypt_token(tenant_id, user_id)
    token = encryptor.encrypt_and_sign("#{tenant_id}:#{user_id}")
  end

  def decrypt_token(token)
    tenant_id, user_id = encryptor.decrypt_and_verify(token).split(':')
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

end