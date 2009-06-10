class AccountScopedController < ApplicationController

  # this defines most of our authentication and scoping routines
  # and also the catch/drop interface
  # (since users are not collected)
  
  helper_method :current_account, :current_user_session, :current_user, :current_collection
  helper_method :logged_in?, :admin?, :account_admin?
  before_filter :require_account
  before_filter :require_user
  layout 'inside'

  def current_collection
    nil
  end

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
    
  def with_default_subdomain(link)
    # force links to general site
  end
  
  def with_account_subdomain(link)
    # force links to local site
  end
  
  
  
  
  
  def catch
    # identify catching object
    # identify dropped object
    # call catching.catch_this(dropped)
    # return json response
  end
  
  def drop
    # identify dropping object
    # identify dropped object
    # call dropping.drop_this(dropped)
    # return json response
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
  
  def admin?
    current_user.admin?    
  end
  
  def account_admin?
    current_user == current_account.user
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
  
  def require_admin
   false unless current_user && current_user.admin?
  end
  
  def require_account_admin
   false unless current_user && current_user.account_holder?
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
      redirect_to root_url
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
  
end
