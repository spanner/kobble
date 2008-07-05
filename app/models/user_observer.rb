class UserObserver < ActiveRecord::Observer

  cattr_accessor :current_user

  def after_create(user)
    if user.activated?
      UserNotifier.deliver_account_details(user)
    elsif user == current_user
      UserNotifier.deliver_welcome(user)
    else
      UserNotifier.deliver_invitation(user, current_user)
    end
  end
  
  def after_update(user)
    after_create(user)
  end

end