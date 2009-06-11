class AccountScopedController < ApplicationController

  # this defines most of our authentication and scoping routines
  # and also the catch/drop interface
  # (since users are not collected)
  
  helper_method :current_account, :current_user_session, :current_user, :current_collection
  helper_method :logged_in?, :admin?, :account_admin?

  before_filter :require_account
  before_filter :require_user

  before_filter :get_working_class
  before_filter :get_item, :only => [:show, :edit, :update, :destroy, :catch, :drop]
  before_filter :get_deleted_item, :only => [:recover, :eliminate]
  before_filter :get_items, :only => [:index]
  before_filter :build_item, :only => [:new, :create]

  after_filter :update_index, :only => [:create, :update, :destroy, :describe]

  layout 'inside'

  def current_collection
    nil
  end

  def index
    render :template => 'shared/list'
  end

  def new; end

  def create
    if @thing.save
      flash[:notice] = "#{@thing.nice_title} created."
      redirect_to url_for(@thing)
    else
      flash[:error] = "failed to create"
      render :action => 'new'
    end
  end

  def show
  rescue ActiveRecord::RecordNotFound
    @thing = model_class.find_only_deleted(params[:id])
    render :template => 'shared/deleted'
  end
  
  def edit; end

  def update
    if @thing.update_attributes(params[:thing])
      flash[:notice] = "#{model_class} was successfully updated."
      redirect_to url_for(@thing)
    else
      flash[:notice] = 'failed to update.'
      render :action => 'edit'
    end
  end

  def destroy
    @thing.reassign_to = model_class.find(params[:reassign_to]) if params[:reassign_to] && @thing.respond_to?('reassign_to')
    @thing.class.transaction { @thing.destroy }
    flash[:notice] = "#{@deleted.name} has been deleted"
    @response = Kobble::Response.new("#{@thing.name} deleted", 'delete')
    thing_or_response
  rescue => e
    flash[:error] = e.message
    @response = Kobble::Response.new(e.message, '', 'failure')
    thing_or_response
  end

  def recover
    model_class.transaction {
      @thing.recover!
    }
    flash[:notice] = "#{@recovered.name} recovered"
    respond_to do |format|
      format.html { redirect_to url_for(@thing) }
      format.json { render :json => @thing.to_json }
    end
  end
  
  def eliminate
    model_class.transaction {
      @thing.logged_events.each { |e| e.destroy }
      @thing.destroy_without_callbacks!
    }
    respond_to do |format|
      format.html { render :template => 'shared/eliminated' }
      format.json { render :json => @thing.to_json }
    end
  end

  def catch
    @dropped = thing_from_tag(params[:dropped])
    
    logger.warn ">>> #{self.class.to_s.downcase}.catch_this #{@dropped.class.to_s.downcase}"
    
    @response = @thing.catch_this(@dropped)
    respond_to do |format|
      format.html { render :partial => 'shared/caught' }
      format.json { render :json => @response.to_json }
    end
  end
  
  def drop
    @dropped = thing_from_tag(params[:dropped])
    @response = @thing.drop_this(@dropped)
    respond_to do |format|
      format.html { render :partial => 'shared/dropped' }
      format.json { render :json => @response.to_json }
    end
  end

protected
  
  # account-subdomain helpers
  
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

  # authentication helpers

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

  # crud before_filters
  # other controllers may override these to scope to a collection, user or object

  def get_item
    @thing = current_account.send(association).find(params[:id])
  end
  
  def get_deleted_item
    @thing = current_account.send(association).find_only_deleted(params[:id])
  end

  def build_item
    @thing = current_account.send(association).build(params[:thing])
  end
  
  def get_items
    @list = current_account.send(association).paginate(paging)
  end
  
  def paging
    {
      :page => params[:page] || 1,
      :per_page => params[:per_page] || 100,
    }
  end

  # model abstraction

  def get_working_class
    @klass = model_class
  end
  
  def model_class
    working_on.as_class
  end

  def association
    working_on.downcase.pluralize.intern
  end

  def parameter_head
    working_on.downcase.intern
  end

  def working_on
    request.parameters[:controller].singularize.to_s
  end  
  
  # access-control helpers
  
  def logged_in?
    current_account && current_user
  end
  
  def admin?
    current_user.admin?    
  end
  
  def account_admin?
    current_user == current_account.user
  end

  # access control before_filters
  
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

  # generic responses

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
  def thing_or_response
    respond_to do |format|
      format.html { redirect_to url_for(@thing) }
      format.json { render :json => @response.to_json }
    end
  end

private

  def thing_from_tag(tag)
    klass, id = tag.split('_')
    klass.as_class.find(id) 
  rescue
    nil
  end

  def update_index
    if ActsAsXapian::ActsAsXapianJob.count > 0
      spawn(:nice => 7) do
        %x(rake xapian:update_index) 
      end
    end
  end
  
end
