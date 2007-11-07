class EditObserver < ActiveRecord::Observer
  observe Source, Node, Bundle, Tag, Occasion, Warning, Question, Survey, Blogentry, Forum, Topic, Post, UserGroup
  
  cattr_accessor :current_user
  
  def before_create(model)
    model.collection = Collection.current_collection
    model.creator = @@current_user
  end
  
  def before_update(model)
    model.updater = @@current_user
  end
end
