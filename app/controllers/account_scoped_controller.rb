class AccountScopedController < ApplicationController

  # this defines most of our authentication and scoping routines
  # but not much else.

  helper_method(:current_account, :current_user_session, :current_user, :logged_in?, :account_domain, :account_subdomain, :account_url, :default_account_subdomain, :default_account_url, :current_collection)
  before_filter :require_account
  before_filter :require_user
  layout 'inside'

protected
  
  def request_domain
    '' << request.domain << request.port_string
  end
  
  def request_subdomain
    request.subdomains.last || ''
  end
  
  def default_subdomain
    'www'
  end
  
  def current_site
    [request_subdomain, request_domain].join('.')
  end
  
  def default_site
    [default_subdomain, request_domain].join('.')
  end
  
  def current_url
    current_protocol + current_site
  end      

  def default_url
    default_protocol + default_site
  end      
      
  def current_protocol
    request.ssl? ? "https://" : "http://"
  end
  
  def default_protocol
    "http://"
  end
    
  def with_default_subdomain
    # force links to general site
  end
  
  def with_account_subdomain
    # force links to local site
  end
  
  

private

  def current_account
    return @current_account if defined?(@current_account)
    @current_account = Account.find_by_subdomain(request_subdomain)
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end
  
  def logged_in?
    current_account && current_user
  end
  
  def require_account
    if current_account
      Account.current = current_account
    else
      store_location
      flash[:notice] = "Please log into your account space"
      redirect_to root_url, :host => default_site
      return false
    end
  end

  def require_user
    if current_user
      User.current = current_user
    else
      store_location
      flash[:notice] = "Please log in"
      redirect_to new_user_session_url
      return false
    end
  end

  def require_no_account
    if current_account
      store_location
      flash[:notice] = "Not an account page"
      redirect_to :host => default_site
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must log out to see that page"
      redirect_to dashboard_url
      return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
  def current_collection
    nil
  end

end
