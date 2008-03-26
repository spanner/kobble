class EditObserver < ActiveRecord::Observer
  observe Source, Node, Bundle, Tag, Scratchpad, Occasion, Flag, Topic, Post
  
  cattr_accessor :current_user
  
  def before_create(model)
    model.creator = @@current_user
  end
  
  def before_update(model)
    model.updater = @@current_user
  end
end
