class EditObserver < ActiveRecord::Observer
  observe Collection, Source, Node, Bundle, Tag, Occasion, Topic, Post, Annotation

  def before_validation_on_create(model)
    model.collection ||= Collection.current unless model.is_a?(Collection)
    model.created_by = User.current
  end
  
  def before_update(model)
    # model.just_changed = model.changed.to_sentence
    model.updated_by = User.current
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
    collection = model if model.is_a?(Collection)
    collection ||= model.has_collection? ? model.collection : nil
    collection.last_active_at = Time.now if collection && !collection.frozen?

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
