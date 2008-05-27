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

end
