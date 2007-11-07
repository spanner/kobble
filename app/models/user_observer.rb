class UserObserver < ActiveRecord::Observer

  cattr_accessor :current_user

  def after_create(user)
    if (user.can_login?) then
      UserNotifier.deliver_signup_notification(user, Collection.current_collection)
    end
  end

  def after_save(user)
    if (!user.email.nil? && user.can_login?) then
      UserNotifier.deliver_activation(user, Collection.current_collection) if user.recently_activated?
    end
  end
end