# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include StringExtensions

  before_filter :login_required
  before_filter :set_context
  layout :choose_layout
  
  def set_context
    @display = 'list'
    EditObserver.current_user = current_user
    Collection.current_collection = UserObserver.current_collection = EditObserver.current_collection = @current_collection = current_collection
    redirect_to :controller => 'collections', :action => 'index' unless @current_collection
  end
  
  def limit_to_active_collection
    ["collection_id = ?", current_collection]
  end
  
  def choose_layout
    logged_in? && activated? ? 'standard' : 'login'
  end
    
  def local_request?
    logged_in? && current_user.is_admin? == 'admin'
  end
  
  def tags_from_list (taglist)
    tags = taglist.split(/[,;]\s*/).uniq
    tags.map! { |name| Tag.find_or_create_by_name( name ) }
    tags
  end
  
end
