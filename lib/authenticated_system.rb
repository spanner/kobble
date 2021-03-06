module AuthenticatedSystem
  protected

    def logged_in?
      current_user != :false
    end

    def activated?
      logged_in? && current_user.activated?
    end

    def developer?
      logged_in? && current_user.developer?
    end

    def admin?
      logged_in? && current_user.admin?
    end

    def account_admin?
      logged_in? && current_user.account_admin?
    end
    
    def account_holder?
      logged_in? && current_user.account_holder?
    end
    
    def current_user
      @current_user ||= User.find_by_id(session[:user]) if session[:user]
    end
    
    def current_account
      @current_account ||= current_user.account
    end
    
    def current_user=(user)
      session[:user] = user.id
      @current_user = EditObserver.current_user = user
      update_last_seen_at
    end

    def current_collection
      @current_collection ||= current_account.collections.find_by_id(session[:collection]) if session[:collection]
      raise Kobble::CollectionNotChosen unless @current_collection
      @current_collection
    end
    
    def current_collection=(collection)
      session[:collection] = collection.id
      @current_collection = Collection.current = current_collection
      update_last_seen_at
    end
    
    def update_last_seen_at
      return unless logged_in?
      User.update_all ['last_seen_at = ?', Time.now.utc], ['id = ?', current_user.id] 
      current_user.last_seen_at = Time.now.utc
    end
    
    # Check if the user is authorized.
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the user
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorize?
    #    current_user.login != "bob"
    #  end
    def authorized?
      current_user.can_login?
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      username, passwd = get_auth_data
      self.current_user = User.authenticate(username, passwd) || :false if username && passwd
      logged_in? ? true : access_denied
    end
    
    # Filter methods to enforce status requirements.
    #
    # To require admin? for all actions, use this:
    #
    #   before_filter :admin_required
    #
    # likewise :account_admin_required and :developer_required
    #
    # other options as for :login_required and other filters

    def admin_required
      return false unless login_required
      admin? ? true : access_insufficient
    end

    def account_admin_required
      return false unless login_required
      account_admin? ? true : access_insufficient
    end

    def developer_required
      return false unless login_required
      developer? ? true : access_insufficient
    end

    def activation_required
      return false unless login_required
      activated? ? true : access_inactive
    end
    
    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    
    def access_denied
      logger.warn "!!! access_denied"
      respond_to do |accepts|
        accepts.html do
          store_location
          redirect_to :controller => '/login', :action => 'login'
        end
        accepts.xml do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "Could't authenticate you", :status => '401 Unauthorized'
        end
      end
      false
    end  
    
    def access_insufficient
      logger.warn "!!! access_insufficient"
      respond_to do |accepts|
        accepts.html do
          store_location
          redirect_to :controller => '/login', :action => 'forbidden'
        end
        accepts.xml do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "Insufficient authority", :status => '401 Unauthorized'
        end
      end
      false
    end  
    
    def access_inactive
      logger.warn "!!! access_inactive"
      respond_to do |accepts|
        accepts.html do
          store_location
          redirect_to :controller => '/login', :action => 'index'
        end
        accepts.xml do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "Account not activated", :status => '401 Unauthorized'
        end
      end
      false
    end
    
    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri unless request.request_uri == '/login'
    end
    
    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      session[:return_to] ? redirect_to(session[:return_to]) : redirect_to(default)
      session[:return_to] = nil
    end
    
    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?
    end

    # When called with before_filter :login_from_cookie will check for an :auth_token
    # cookie and log the user back in if apropriate
    def login_from_cookie
      return unless !logged_in? && cookies[:auth_token]
      user = User.find_by_remember_token(cookies[:auth_token])
      if user && user.remember_token?
        self.current_user = user
        cookies[:auth_token] = user.remember_me
      end
    end

  private
    @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
    # gets BASIC auth info
    def get_auth_data
      auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
      auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
      return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil] 
    end
end
