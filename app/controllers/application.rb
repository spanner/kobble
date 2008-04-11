# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  include AuthenticatedSystem
  include StringExtensions
  include ExceptionNotifiable

  helper_method :current_user, :current_account, :current_collections, :logged_in?, :activated?, :admin?, :editor?, :account_holder?, :last_active
  before_filter :login_from_cookie
  before_filter :login_required
  before_filter :set_context
  before_filter :check_activations  
  layout 'standard'
  exception_data :exception_report_data
  
  def index
    list
  end
  
  def set_context
    if logged_in?
      @scratch = current_user.find_or_create_scratchpads 
      EditObserver.current_user = current_user
    end
  end
  
  def check_activations
    redirect_to :controller => 'accounts', :action => 'home' if current_collections.empty?
    Collection.current_collections = current_collections
  end
  
  def limit_to_this_account(klass=nil)
    t = klass ? "#{klass.table_name}." : ''
    ["#{t}account_id = ?", current_account]
  end

  def limit_to_active_collections(klass=nil)
    [active_collections_clause(klass)] + current_collections.map { |c| c.id }
  end
  
  def limit_to_active_collections_and_visible(klass=nil)
    t = klass ? "#{klass.table_name}." : ''
    [active_collections_clause(klass) + " and #{t}visibility <= ?"] + current_collections + [current_user.status]
  end

  def limit_to_active_collections_and_this_week(klass=nil)
    t = klass ? "#{klass.table_name}." : ''
    [active_collections_clause(klass) + " and #{t}created_at >= ?", current_collection, (Time.now - (86400 * 7)).utc]
  end

  def active_collections_clause(klass=nil)
    t = klass ? "#{klass.table_name}." : ''
    "#{t}collection_id in (" + current_collections.map{'?'}.join(',') + ")"
  end

  def local_request?
    admin?
  end
    
  # shared retrieval mechanisms

  def search
    @klass = request.parameters[:controller].to_s._as_class
    @search = Ultrasphinx::Search.new(
      :query => params[:q],
      :page => params[:page] || 1, 
      :per_page => 20,
      :class_names => @klass
    )
    @search.run
    render :template => 'search/results'
  end
  
  def list
    @list = paged_list
    respond_to do |format|
      format.html { render :template => 'shared/list' }
      format.js { render :template => 'shared/list', :layout => false }
    end
  end

  def gallery
    @list = paged_list
    respond_to do |format|
      format.html { render :template => 'shared/gallery' }
      format.js { render :template => 'shared/gallery', :layout => false }
    end
  end
  
  def paged_list
    @klass = request.parameters[:controller].to_s._as_class
    page = params[:page] || 1
    perpage = params[:perpage] || self.list_length
    sort_options = request.parameters[:controller].to_s._as_class.sort_options
    sort = sort_options[params[:sort]] || sort_options[request.parameters[:controller].to_s._as_class.default_sort]
    conditions = limit_to_active_collections
    @list = @klass.paginate :conditions => conditions, :order => sort, :page => page, :per_page => perpage
  end
    
  def views
    ['gallery']
  end
  
  def list_columns
    2
  end

  def list_length
    40
  end

  def catch
    @catcher = request.parameters[:controller].to_s._as_class.find( params[:id] )
    @caught = params[:caughtClass].to_s._as_class.find( params[:caughtID] )
    # catch_object method is inserted by acts_as_catcher and dispatches to appropriate instance method
    @response = @catcher.catch_object(@caught) if @catcher and @caught                     
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
  
  def amend
    # single field update
  end

  def trash
    @trashed = request.parameters[:controller].to_s._as_class.find( params[:id] )
    # permissions check!
    @trashed.destroy
    @response = CatchResponse.new("#{@trashed.name} deleted", 'delete')
    respond_to do |format|
      format.html { redirect_to :controller => params[:controller], :action => 'list' }
      format.json { render :json => @response.to_json }
      format.xml { head 200 }
    end
  rescue => e
    flash[:error] = e.message
    @response = CatchResponse.new(e.message, '', 'failure')
    respond_to do |format|
      format.html { 
        flash[:error] = e.message
        redirect_to :controller => params[:controller], :action => 'show', :id => @trashed 
      }
      format.json { render :json => @response.to_json }
      format.xml { head 200 }
    end
  end
  
  def drop
    @dropper = request.parameters[:controller].to_s._as_class.find( params[:id] )
    @dropped = params[:droppedClass]._as_class.find(params[:droppedID])
    # drop_object method is inserted by acts_as_catcher and dispatches to appropriate instance method
    @response = @dropper.drop_object(@dropped) if @dropper and @dropped
    respond_to do |format|
      format.html { redirect_to :controller => params[:controller], :action => 'show', :id => @dropper }
      format.json { render :json => @response.to_json }
      format.xml { head 200 }
    end
  rescue => e
    @response = CatchResponse.new(e.message, '', 'failure')
    respond_to do |format|
      format.html { 
        flash[:error] = e.message
        redirect_to :controller => params[:controller], :action => 'show', :id => @catcher 
      }
      format.json { render :json => @response.to_json }
      format.xml { head 200 }
    end
  end
  
  def dropped
    render :layout => false
  end

  def tags_from_list (taglist)
    Tag.from_list(taglist)
  end
  
  protected
    def last_active
      session[:last_active] ||= Time.now.utc
    end
    
    def rescue_action(exception)
      exception.is_a?(ActiveRecord::RecordInvalid) ? render_invalid_record(exception.record) : super
    end

    def render_invalid_record(record)
      render :action => (record.new_record? ? 'new' : 'edit')
    end

    def exception_report_data
      {
        :user => current_user,
        :collections => current_collections
      }
    end
end
