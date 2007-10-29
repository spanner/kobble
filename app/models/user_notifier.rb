class UserNotifier < ActionMailer::Base
  def signup_notification(user, collection)
    setup_email(user, collection)
    @subject    += 'Please activate your new account'
    @body[:url]  = "http://#{collection.url}/account/activate/#{user.activation_code}"
    @body[:code]  = user.activation_code
  end
  
  def activation(user, collection)
    setup_email(user, collection)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "#{collection.url}/account"
  end

  def newpassword(user, collection)
    setup_email(user, collection)
    @subject    += 'Your provisional new password'
    @body[:url]  = "http://#{collection.url}/account/fixpassword/#{user.activation_code}"
    @body[:code]  = user.activation_code
    @body[:password]  = user.new_password
  end
  
  protected
  def setup_email(user, collection)
    @recipients  = "#{user.email}"
    @from        = "william.ross@sparknow.net"
    @subject     = "#{collection.name}: "
    @sent_on     = Time.now
    @body[:user] = user
    @body[:collection] = collection
  end
end
