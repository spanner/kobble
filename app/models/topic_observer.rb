class TopicObserver < ActiveRecord::Observer
    
  def after_create(topic)
    monitors = topic.monitors + User.everything_monitors
    monitors.push topic.referent.creator if topic.referent.creator.prefers? 'notify_comments'
    monitors.each do |user|
      UserNotifier.deliver_topic_notification(user, topic) unless user == topic.creator
    end
  end
  
end
