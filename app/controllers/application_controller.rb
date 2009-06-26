class ApplicationController < ActionController::Base
  helper :all
  filter_parameter_logging :password, :password_confirmation

  # only context and utility methods here:
  # most kobble classes get their auth from AccountScopedController
  # and their crud from CollectionScopedController
  
  layout 'outside'
  
  def collected_url_for(thing)
    return url_for(thing) if thing.is_a?(Collection)
    url_method = "#{thing.class.to_s.downcase}_url".intern
    return send(url_method) unless thing.respond_to?(:collection)
    send(url_method, current_collection.id, thing)
  end

end
