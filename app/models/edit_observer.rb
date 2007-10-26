class EditObserver < ActiveRecord::Observer
  observe User, Source, Node, Bundle, Tag, Occasion, Warning, Question, Survey, Blogentry, Forum, Topic, Post
  
  cattr_accessor :current_user
  cattr_accessor :current_collection
  
  def before_create(model)
    
    STDERR.puts("!!! giving custody to #{@@current_user.name}. current_user method call returns #{current_user.name}")
    
    model.collection = @@current_collection
    model.creator = @@current_user
    model.created_at = Time.now
  end
  
  def before_update(model)
    model.updater = @@current_user
    model.updated_at = Time.now
  end
end
