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

  def welcome(user)
    
    
  end

  protected
  def setup_email(user)
    # @content_type = user.receive_html_email ? 'text/html' : 'text/plain'
    @content_type = 'text/plain'
    @recipients  = "#{user.email}"
#   @from        = "#{collection.email_from}"
    @subject     = "[spoke] "
    @sent_on     = Time.now
    @body[:user] = user
    @body[:prefsurl] = "http://materiali.st/accounts/me"
  end
end
