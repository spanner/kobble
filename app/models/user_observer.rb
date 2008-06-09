class UserObserver < ActiveRecord::Observer

  cattr_accessor :current_user

  def after_create(user)
    UserNotifier.deliver_welcome(user)
  end

end