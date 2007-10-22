class UserObserver < ActiveRecord::Observer

  cattr_accessor :current_user
  cattr_accessor :current_collection

  def after_create(user)
    if (!user.email.nil? && user.can_login?) then
      UserNotifier.deliver_signup_notification(user, @@current_collection)
    end
  end

  def after_save(user)
    if (!user.email.nil? && user.can_login?) then
      UserNotifier.deliver_activation(user, @@current_collection) if user.recently_activated?
    end
  end
end