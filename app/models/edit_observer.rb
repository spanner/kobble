class EditObserver < ActiveRecord::Observer
  observe User, Source, Node, Bundle, Tag, Warning, Question, Survey
  
  cattr_accessor :current_user
  cattr_accessor :current_collection
  
  def before_create(model)
    model.collection = @@current_collection
    model.created_by = @@current_user
    model.created_at = Time.now
  end
  
  def before_update(model)
    model.updated_by = @@current_user
    model.updated_at = Time.now
  end
end
