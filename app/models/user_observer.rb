class UserObserver < ActiveRecord::Observer

  cattr_accessor :current_user

  def after_create(user)
    if user == current_user
      UserNotifier.deliver_welcome(user, current_user)
    else
      UserNotifier.deliver_invitation(user, current_user)
    end
  end

end