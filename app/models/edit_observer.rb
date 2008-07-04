class EditObserver < ActiveRecord::Observer
  observe Collection, Source, Node, Bundle, Tag, Occasion, Topic, Post, Annotation
  
  cattr_accessor :current_user
  
  def before_create(model)
    model.creator = @@current_user if model.record_timestamps
  end
  
  def before_update(model)
    model.updater = @@current_user if model.record_timestamps
  end
 
  def after_create(model)
    if model.class == Annotation
      record_event(model.annotated, 'annotated')
    else
      record_event(model, 'created')
    end
  end

  def after_update(model)
    if model.newly_undeleted
      record_event(model, 'restored') if model.record_timestamps
    else
      record_event(model, 'updated') if model.record_timestamps
    end
  end

  def after_destroy(model)
    record_event(model, 'deleted')
  end

  def record_event(model, type)
    collection = model if model.class == Collection
    collection ||= model.has_collection? ? model.collection : nil
    collection.last_active_at = Time.now if collection
    @@current_user.last_active_at = Time.now unless @@current_user.nil?

    Event.create({
      :affected => model,
      :user => (@@current_user unless @@current_user.nil?),
      :account => (@@current_user.account unless @@current_user.nil?),
      :collection => collection,
      :affected_name => model.name,
      :event_type => type,
      :at => Time.now
    })
  end

end
