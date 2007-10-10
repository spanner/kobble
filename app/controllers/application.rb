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
    Collection.current_collection = EditObserver.current_collection = @current_collection = current_collection
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
  
  def kwtree
    tags = Keyword.find(:all, :include => :parent)
    tags.collect{ |kw| kw.parentage }.sort!
  end

  def tags_from_list (branchlist)
    return unless branchlist;
    branches = branchlist.split(/[,;]\s*/)
    branches.collect!{ |b| 
      Keyword.find_or_create_branch( b.split(/\/\s*/) )
    }
  end
  
end
