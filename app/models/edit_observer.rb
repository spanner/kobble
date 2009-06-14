class EditObserver < ActiveRecord::Observer
  observe Collection, Source, Node, Bundle, Tag, Occasion, Topic, Post, Annotation

  def before_save(model)
    model.collection ||= Collection.current
  end

  def before_create(model)
    model.created_by = User.current if model.record_timestamps
  end
  
  def before_update(model)
    model.updated_by = User.current if model.record_timestamps
  end
 
  def after_create(model)
    if model.record_timestamps
      if model.class == Annotation
        record_event(model.annotated, 'annotated')
      else
        record_event(model, 'created')
      end
    end
  end

  def after_update(model)
    if model.record_timestamps
      if model.newly_undeleted
        record_event(model, 'restored')
      else
        record_event(model, 'updated')
      end
    end
  end

  def after_destroy(model)
    record_event(model, 'deleted')
  end

  def record_event(model, type)
    collection = model if model.class == Collection
    collection ||= model.has_collection? ? model.collection : nil
    collection.last_active_at = Time.now if collection

    Event.create({
      :affected => model,
      :user => (User.current if User.current),
      :account => (User.current.account if User.current),
      :collection => collection,
      :affected_name => model.name,
      :event_type => type,
      :at => Time.now
    })
  end

end
