class ObjectScopedController < AccountScopedController

  # this is an ajax-only partials controller for adding to and removing connections
  # between objects. its children handle drag and drop events.

  skip_before_filter :build_item
  skip_before_filter :get_item
  before_filter :get_scope_object, :only => [:create, :destroy]

protected
  
  def get_scope_object
    @thing = scope_class.find(params["#{get_scope}_id".intern])
  end

  def scope_class
    get_scope.to_s.as_class
  end

  def get_scope
    Kobble.object_models.find { |klass| not params["#{klass.to_s.downcase}_id".intern].blank? }
  end  
  
end
