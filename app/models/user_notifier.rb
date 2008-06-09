class UserNotifier < ActionMailer::Base
  
  def activation(user)
    setup_email(user)
    @subject += 'Your account has been activated!'
    @body[:url] = "http://materiali.st/account"
  end

  def newpassword(user)
    setup_email(user)
    @subject    += 'Your provisional new password'
    @body[:url]  = "http://materiali.st/login/fixpassword/#{user.activation_code}"
    @body[:code]  = user.activation_code
    @body[:password]  = user.new_password
  end

  def topic(user, topic)
    setup_email(user)
    @subject += "New discussion of '#{topic.subject.name}'"
    @body[:topic] = topic
    @body[:url] = url_for(topic)
  end

  def post(user, post)
    setup_email(user)
    @subject += "New comment under '#{post.topic.name}'"
    @body[:post] = post
    @body[:url] = url_for(post)
  end

  def invitation(user, inviter)
    setup_email(user)
    @subject += "You have been invited to materiali.st"
    @body[:url]  = "http://materiali.st/login/activate/#{user.activation_code}"
    @body[:account] = user.account
    @body[:inviter] = inviter
  end

  def welcome(user, inviter)
    setup_email(user)
    @subject += "Welcome to materiali.st"
    @body[:url]  = "http://materiali.st/login/activate/#{user.activation_code}"
    @body[:account] = user.account
    @body[:inviter] = inviter
  end

  protected
  def setup_email(user)
    @content_type = 'text/plain'
    @recipients  = "#{user.email}"
    @subject     = "[materiali.st] "
    @sent_on     = Time.now
    @body[:user] = user
    @body[:prefsurl] = "http://materiali.st/accounts/me"
  end
end
