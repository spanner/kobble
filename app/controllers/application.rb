# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include StringExtensions

  helper_method :current_user, :current_collection, :logged_in?, :admin?, :editor?, :last_active
  before_filter :editor_required  
  before_filter :set_context
  layout :choose_layout
  
  def set_context
    @display = 'list'
    EditObserver.current_user = current_user
    Collection.current_collection = UserObserver.current_collection = EditObserver.current_collection = current_collection
    redirect_to :controller => 'collections', :action => 'index' if logged_in? && current_collection == :false
  end
  
  def limit_to_active_collection
    ["collection_id = ?", current_collection]
  end
  
  def limit_to_active_collection_and_visible
    ["collection_id = ? and visibility <= ?", current_collection, current_user.status]
  end

  def choose_layout
    return 'standard' if logged_in? && editor?
    return current_collection.abbreviation.to_s if current_collection
    return 'login'
  end
    
  def local_request?
    admin?
  end
  
  def tags_from_list (taglist)
    tags = taglist.split(/[,;]\s*/).uniq
    tags.map! { |name| Tag.find_or_create_by_name( name ) }
    tags
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
  
end
