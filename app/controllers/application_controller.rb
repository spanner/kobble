class ApplicationController < ActionController::Base
  helper :all
  filter_parameter_logging :password, :password_confirmation

  # only context and utility methods here:
  # most kobble classes get their auth from AccountScopedController
  # and their crud from CollectionScopedController
  
  layout 'outside'
  
  def local_request?
    admin?
  end

  def collected_url_for(thing)
    url_method = "#{thing.class.to_s.downcase}_url".intern
    return send(url_method) if thing.is_a?(Collection)
    collection = thing.collection || current_collection
    send(url_method, collection.id, thing)
  end

end
