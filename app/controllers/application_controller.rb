class ApplicationController < ActionController::Base
  helper :all
  filter_parameter_logging :password, :password_confirmation

  # only context and utility methods here:
  # kobble classes get their auth from AccountScopedController
  # and their crud from CollectionScopedController
  
  layout 'outside'
  
  def local_request?
    admin?
  end

end
