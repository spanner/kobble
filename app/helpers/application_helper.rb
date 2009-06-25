# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def collected_url_for(item)
    @controller.send(:collected_url_for, item)
  end
  
  def edit_url_for(item)
    url_method = "edit_#{item.class.to_s.underscore.downcase}_url"
    send url_method.intern, current_collection.id, item.id
  end
  
  def item_tags_path(item)
    url_method = "#{item.class.to_s.underscore.downcase}_tags_path"
    send url_method.intern, current_collection, item
  end

  def item_new_topic_url(item)    
    url_method = 'new_' + item.class.to_s.underscore.downcase + '_topic_url'
    send url_method.intern, current_collection, item
  end

  def item_topics_path(item)    
    url_method = item.class.to_s.underscore.downcase + '_topics_path'
    send url_method.intern, current_collection, item
  end

  def item_create_topic_path(item)    
    url_method = 'create_' + item.class.to_s.underscore.downcase + '_topic_path'
    send url_method.intern, current_collection, item
  end
  
  def item_topic_url(item, topic)
    url_method = item.class.to_s.underscore.downcase + '_topic_url'
    send url_method.intern, item, topic
  end

  def item_new_note_url(item)    
    url_method = 'new_' + item.class.to_s.underscore.downcase + '_annotation_url'
    send url_method.intern, current_collection, item
  end

  def item_notes_path(item)    
    url_method = item.class.to_s.underscore.downcase + '_annotations_path'
    send url_method.intern, current_collection, item
  end

  def item_notes_url(item)    
    url_method = item.class.to_s.underscore.downcase + '_annotations_url'
    send url_method.intern, current_collection, item
  end

  def item_history_url(item)
    url_method = item.class.to_s.underscore.downcase + '_events_url'
    send url_method.intern, item
  end

  def friendly_date(datetime)
    if datetime
      date = datetime.to_date
      if (date == Date.today)
        format = "today at %l:%M%p"
      elsif (date == Date.yesterday)
        format = "yesterday at %l:%M%p"
      elsif (date.year == Date.today.year)
        format = "on %B %e"
      else
        format = "on %B %e, %Y"
      end
      datetime.strftime(format)
    else 
      "unknown date"
    end
  end

  # wraps the block in a p with the right class and shows the errors nicely, if there are any
  
  def with_error_report(errors, &block)
    render({:layout => 'wrappers/field_errors', :locals => {:errors => errors}}, {}, &block)
  end
  
  def icon_for(thing, size=16, color='blue', options={})
    image_name = thing.is_a?(Source) ? thing.file_type : thing.class.to_s.downcase
    image_tag "/images/furniture/kobble/#{size}/#{color}/#{image_name}.png", :size => "#{size}x#{size}", :class => options[:class]
  end

  def gravatar_for(user, size=32)
    image_tag user.gravatar_url(:size => size), :class => 'gravatar', :size => "#{size}x#{size}"
  end
end
