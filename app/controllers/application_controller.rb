class ApplicationController < ActionController::Base

  include AuthenticatedSystem
  include ExceptionNotifiable

  helper_method :current_user, :current_account, :current_collection, :logged_in?, :activated?, :admin?, :account_admin?, :account_holder?, :last_active

  before_filter :login_from_cookie
  before_filter :login_required
  before_filter :set_user_context
  before_filter :set_collection_context, :except => [:home]
  before_filter :set_last_active
  
  # only context and utility methods here:
  # most kobble classes inherit from CollectedController
  # and the rest vary widely
  
  layout 'standard'
  exception_data :exception_report_data
  
  def local_request?
    admin?
  end

  def tags_from_list (taglist)
    Tag.from_list(taglist)
  end
  
  protected
    def set_user_context
      User.current = current_user if logged_in?
    end
  
    def set_collection_context
      Collection.current = current_collection if logged_in?
    rescue Kobble::AccessDenied
      flash[:error] = "Sorry: you don't have permission to access that."
      redirect_to dashboard_url
    rescue Kobble::CollectionNotChosen
      redirect_to dashboard_url
    end

    def set_last_active
      current_user.last_active_at = current_user.account.last_active_at = Time.now.utc
    end
    
    def exception_report_data
      {
        :user => current_user,
        :collection => current_collection
      }
    end

end
