class TopicObserver < ActiveRecord::Observer
    
  def after_create(topic)
    topic.collection = topic.referent.collection if topic.referent.has_collection?
    monitors = topic.monitors + User.everything_monitors
    # monitors.push topic.referent.created_by if topic.referent.created_by.prefers? 'notify_comments'
    monitors.each do |user|
      UserNotifier.deliver_topic_notification(user, topic) unless user == topic.created_by
    end
  end

  def after_update(topic)
    topic.collection = topic.referent.collection if topic.referent.has_collection?
  end

end
