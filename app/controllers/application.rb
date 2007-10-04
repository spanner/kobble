# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'localization'
require 'user_system'

class ApplicationController < ActionController::Base
  include Localization
  include UserSystem
  helper :user
  model  :user
  before_filter :login_required
  before_filter :set_context
  layout :choose_layout
  
  def set_context
    if session['user'] then
      @user = User.find(session['user'])
      @active_collection = @user.collection
      @display = 'list'
    end
  end
  
  def limit_to_active_collection
    ["collection_id = ?", @active_collection]
  end
  
  def choose_layout
    session['user'] ? 'standard' : 'login'
  end
    
  def local_request?
    session['user'] && @user.role == 'admin'
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
