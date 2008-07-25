class UserObserver < ActiveRecord::Observer

  cattr_accessor :current_user

  def before_update(user)
    if user.activated_at_changed?
      user.newly_activated = true
    elsif user.login_changed? or user.password_changed?
      user.notify_of_login = true
    end
  end

  def after_create(user)
    if user.record_timestamps
      if user == current_user
        UserNotifier.deliver_welcome(user)
      else
        UserNotifier.deliver_invitation(user, current_user)
      end
    end
  end
  
  def after_update(user)
    if user.record_timestamps
      if user.notify_of_login
        UserNotifier.deliver_account_details(user)
      elsif user.newly_activated
        UserNotifier.deliver_activation(user)
      end
    end
  end

end