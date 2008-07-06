# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def item_new_topic_url(item)    
    url_method = 'new_' + item.class.to_s.underscore.downcase + '_topic_url'
    eval(url_method + '(item)')
  end

  def item_topics_path(item)    
    url_method = item.class.to_s.underscore.downcase + '_topics_path'
    eval(url_method + '(item)')
  end

  def item_create_topic_path(item)    
    url_method = 'create_' + item.class.to_s.underscore.downcase + '_topic_path'
    eval(url_method + '(item)')
  end

  def item_new_note_url(item)    
    url_method = 'new_' + item.class.to_s.underscore.downcase + '_annotation_url'
    eval(url_method + '(item)')
  end

  def item_notes_path(item)    
    url_method = item.class.to_s.underscore.downcase + '_annotations_path'
    eval(url_method + '(item)')
  end

  def item_create_note_path(item)    
    url_method = 'create_' + item.class.to_s.underscore.downcase + '_annotation_path'
    eval(url_method + '(item)')
  end

  def item_history_url(item)
    url_method = item.class.to_s.underscore.downcase + '_events_url'
    eval(url_method + '(item)')
  end

  def friendly_date(datetime)
    today = Date.today
    date = datetime.to_date
    if (date == Date.today)
      format = "Today at %l:%M%p"
    elsif (date == Date.yesterday)
      format = "Yesterday at %l:%M%p"
    elsif (date.year == Date.today.year)
      format = "%B %e at %l:%M%p"
    else
      format = "%B %e %Y at %l:%M%p"
    end
    datetime.strftime(format)
  end

end
