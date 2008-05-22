class EditObserver < ActiveRecord::Observer
  observe Collection, Source, Node, Bundle, Tag, Occasion, Flag, Topic, Post
  
  cattr_accessor :current_user
  
  def before_create(model)
    model.creator = @@current_user if model.record_timestamps
  end
  
  def before_update(model)
    model.updater = @@current_user if model.record_timestamps
  end
 
  def after_create(model)
    record_event(model, 'created')
  end

  def after_update(model)
    record_event(model, 'updated') if model.record_timestamps
  end

  def after_destroy(model)
    record_event(model, 'deleted')
  end

  def record_event(model, type)
    model.collection.last_active_at = Time.now if model.has_collection?
    @@current_user.last_active_at = Time.now unless @@current_user.nil?
    Event.create({
      :affected => model,
      :user => (@@current_user unless @@current_user.nil?),
      :account => (@@current_user.account unless @@current_user.nil?),
      :collection => model.class == Collection ? model : model.collection,
      :affected_name => model.name,
      :event_type => type,
      :at => Time.now
    })
  end

end
