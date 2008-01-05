# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include StringExtensions
  include ExceptionNotifiable

  helper_method :current_user, :current_collection, :logged_in?, :activated?, :admin?, :editor?, :last_active
  before_filter :editor_required  
  before_filter :set_context
  layout :choose_layout
  exception_data :exception_report_data

  def index
    list
  end
  
  def set_context
    @display = 'list'
    @scratch = current_user.find_or_create_scratchpads if logged_in?
    EditObserver.current_user = current_user
    Collection.current_collection = User.current_collection = current_collection
    redirect_to :controller => 'collections', :action => 'index' if logged_in? && current_collection == :false
  end
  
  def limit_to_active_collection(klass=nil)
    t = klass ? "#{klass.table_name}." : ''
    ["#{t}collection_id = ?", current_collection]
  end
  
  def limit_to_active_collection_and_visible(klass=nil)
    t = klass ? "#{klass.table_name}." : ''
    ["#{t}collection_id = ? and #{t}visibility <= ?", current_collection, current_user.status]
  end

  def limit_to_active_collection_and_this_week(klass=nil)
    t = klass ? "#{klass.table_name}." : ''
    ["#{t}collection_id = ? and #{t}created_at >= ?", current_collection, (Time.now - (86400 * 7)).utc]
  end

  def choose_layout
    return 'standard' if logged_in? && editor?
    return current_collection.abbreviation.to_s if current_collection
    return 'login'
  end
    
  def local_request?
    admin?
  end
    
  def list
    perpage = params[:perpage] || 50
    sort_options = request.parameters[:controller].to_s._as_class.sort_options
    sort = sort_options[params[:sort]] || sort_options[request.parameters[:controller].to_s._as_class.default_sort]
    @list = request.parameters[:controller].to_s._as_class.find(:all, :conditions => limit_to_active_collection, :order => sort, :page => {:size => perpage, :current => params[:page]})
    respond_to do |format|
      format.html { render :template => 'shared/mainlist' }
      format.js { render :template => 'shared/mainlist', :layout => false }
    end
  end

  def catch
    logger.warn "^^^ catch. 
      controller = #{request.parameters[:controller]}
      class = #{request.parameters[:controller].to_s._as_class}
      id = #{params[:id]}
      json = #{params[:json]}
      klass = #{params[:caughtClass]}
      caught = #{params[:caughtID]}"

    @catcher = request.parameters[:controller].to_s._as_class.find( params[:id] )
    @caught = params[:caughtClass]._as_class.find(params[:caughtID])
    @catcher.catch(@caught) if @catcher and @caught

    respond_to do |format|
      format.html { redirect_to :controller => params[:controller], :action => 'show', :id => @catcher }
      format.js { render :template => 'shared/caught', :layout => false }
      format.xml { head 200 }
    end
  end
  
  def drop
    logger.warn "vvv drop. 
      controller = #{request.parameters[:controller]}
      class = #{request.parameters[:controller].to_s.classify}
      id = #{params[:id]}
      klass = #{params[:klass]}
      caught = #{params[:caught]}"

    @dropper = request.parameters[:controller].to_s._as_class.find( params[:id] )
    @dropped = params[:klass]._as_class.find(params[:dropped])
    @dropper.drop(@dropped) if @dropper and @dropped

    respond_to do |format|
      format.html { redirect_to :controller => params[:controller], :action => 'show', :id => @dropper }
      format.js { render :action => 'dropped', :layout => false }
      format.xml { head 200 }
    end
  end
  
  def dropped
    render :layout => false
  end

  def tags_from_list (taglist)
    branches = taglist.split(/[,;]\s*/).uniq
    branches.collect!{ |b| 
      Tag.find_or_create_branch( b.split(/\:\s*/) )
    }
    # tags.map! { |name| Tag.find_or_create_by_name( name ) }
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
        :collection => current_collection
      }
    end
end
