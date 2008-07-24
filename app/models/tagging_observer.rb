class TaggingObserver < ActiveRecord::Observer
    
  def after_create(tagging)
    tagging.collection = tagging.taggable.collection
    tagging.save
  end

  def after_update(tagging)
    tagging.collection = tagging.taggable.collection
    tagging.save
  end
  
end
