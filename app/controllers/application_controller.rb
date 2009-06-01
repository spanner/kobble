class ApplicationController < ActionController::Base

  include AuthenticatedSystem
  include ExceptionNotifiable

  helper_method :current_user, :current_account, :current_collections, :logged_in?, :activated?, :admin?, :account_admin?, :account_holder?, :last_active
  before_filter :login_from_cookie
  before_filter :login_required
  before_filter :set_context
  before_filter :check_activations
    
  layout 'standard'
  exception_data :exception_report_data
  
  def model_class
    request.parameters[:controller].to_s._as_class
  end
  
  def views
    ['gallery', 'list']
  end

  def view_scope
    return 'user' if params[:user_id] 
    return 'collection' if params[:collection_id] 
    'default'
  end
  
  def index
    list
  end
  
  def set_context
    if logged_in?
      current_user.account.last_active_at = Time.now
      EditObserver.current_user = current_user
      UserObserver.current_user = current_user
    end
  end
  
  def check_activations
    current_user.activate_available_collections if current_collections.empty?
    Collection.current_collections = current_collections
  end
  
  def local_request?
    admin?
  end
    
  # shared retrieval mechanisms

  def show
    @thing = model_class.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    @thing = model_class.find_only_deleted(params[:id])
    render :template => 'shared/deleted'
  end
  
  def list
    @list = paged_list
    @view = 'index'
    respond_to do |format|
      format.html { render :template => 'shared/list' }
      format.js { render :template => 'shared/list', :layout => 'inline' }
    end
  end

  def gallery
    @list = paged_list
    @view = 'gallery'
    respond_to do |format|
      format.html { render :template => 'shared/gallery' }
      format.js { render :template => 'shared/gallery', :layout => 'inline' }
    end
  end
  
  def paged_list
    @klass = model_class
    @scope = view_scope
    case @scope
    when 'account'
      @list = @klass.in_account(current_account).paginate(self.paging)
    when 'user'
      @user = User.find(params[:user_id]) || current_user
      @list = @klass.created_by_user(@user).paginate(self.paging)
    when 'collection'
      @collection = Collection.find(params[:collection_id])
      @list = @klass.in_collection(@collection).paginate(self.paging)
    else
      @list = @klass.in_collections(current_collections).paginate(self.paging)
    end
  end
  
  def paging
    sort_options = model_class.sort_options
    default_sort = model_class.default_sort
    {
      :page => params[:page] || 1,
      :per_page => params[:per_page] || 100,
    }
  end

  def catch
    @catcher = model_class.find( params[:id] )
    @caught = params[:caughtClass].to_s._as_class.find( params[:caughtID] )
    @response = @catcher.catch_this(@caught) if @catcher and @caught
    respond_to do |format|
      format.html { redirect_to :controller => params[:controller], :action => 'show', :id => @catcher }
      format.json { render :json => @response.to_json }
      format.xml { head 200 }
    end
  rescue => e
    @outcome = 'failure';
    @message = e.message
    flash[:error] = e.message
    respond_to do |format|
      format.html { redirect_to :controller => params[:controller], :action => 'show', :id => @catcher }
      format.json { 
        render :json => {
          :outcome => @outcome,
          :message => @message,
        }.to_json 
      }
      format.xml { head 200 }
    end
  end
    
  def drop
    @dropper = model_class.find( params[:id] )
    @dropped = params[:droppedClass]._as_class.find(params[:droppedID])
    @response = @dropper.drop_this(@dropped) if @dropper and @dropped
    respond_to do |format|
      format.html { redirect_to url_for(@dropper) }
      format.json { render :json => @response.to_json }
      format.xml { head 200 }
    end
  rescue => e
    flash[:error] = e.message
    @response = Material::CatchResponse.new(e.message, '', 'failure')
    respond_to do |format|
      format.html { redirect_to url_for(@catcher) }
      format.json { render :json => @response.to_json }
    end
  end
  
  def dropped
    render :layout => false
  end
  
  # most models, including linkers, are paranoid
  
  def destroy
    @deleted = model_class.find( params[:id] )
    @deleted.reassign_to = model_class.find(params[:reassign_to]) if params[:reassign_to] && @deleted.respond_to?('reassign_to')
    model_class.transaction { @deleted.destroy }
    flash[:notice] = "#{@deleted.name} has been deleted"
    @newly_deleted = @deleted
    respond_to do |format|
      format.html { redirect_to url_for(@deleted) }
      format.json { render :json => Material::CatchResponse.new("#{@deleted.name} deleted", 'delete').to_json }
    end
  rescue => e
    logger.warn("@@@ #{e.message}")
    flash[:error] = e.message
    respond_to do |format|
      format.html { redirect_to url_for(@deleted) }
      format.json { render :json => Material::CatchResponse.new(e.message, '', 'failure').to_json }
    end
  end

  def recover
    @recovered = model_class.find_with_deleted( params[:id] )
    @recovered.recover!
    flash[:notice] = "#{@recovered.name} recovered"
    respond_to do |format|
      format.html { redirect_to url_for(@recovered) }
      format.json { render :json => @recovered.to_json }
    end
  end
  
  def eliminate
    @thing = model_class.find_with_deleted(params[:id])
    model_class.transaction {
      @thing.logged_events.each { |e| e.destroy }
      @thing.destroy_without_callbacks!
    }
    respond_to do |format|
      format.html { render :template => 'shared/eliminated' }
      format.json { render :json => @recovered.to_json }
    end
  end
  
  def tags_from_list (taglist)
    Tag.from_list(taglist)
  end
  
  protected
    def last_active
      session[:last_active] ||= Time.now.utc
    end
    
    def exception_report_data
      {
        :user => current_user,
        :collections => current_collections
      }
    end
end
