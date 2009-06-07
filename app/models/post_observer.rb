class PostObserver < ActiveRecord::Observer
    
  def after_create(post)
    monitors = post.topic.monitors + User.everything_monitors
    monitors.each do |user|
      UserNotifier.deliver_post_notification(user, post) unless user == post.created_by
    end
  end
  
end
