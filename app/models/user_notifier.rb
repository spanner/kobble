class UserNotifier < ActionMailer::Base
  
  def activation(user)
    setup_email(user)
    @subject += 'Your account has been activated!'
    @body[:url] = "http://materiali.st/account"
  end

  def password_reset(user)
    setup_email(user)
    @subject    += 'Reset your password'
    @body[:token] = user.perishable_token
    @body[:url] = repassword_url(user, user.perishable_token)
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
    @subject += "You have been invited to kobble"
    @body[:url]  = activate_user_url(user, user.perishable_token)
    @body[:inviter] = inviter
  end

  def welcome(user)
    setup_email(user)
    @subject += "Welcome to kobble"
    @body[:url]  = activate_user_url(user, user.perishable_token)
  end

  def account_details(user)
    setup_email(user)
    @subject += "Your account at materiali.st"
  end

  protected
  def setup_email(user)
    default_url_options[:host] = "#{user.account.subdomain}.kobble.net"
    @from = "William Ross <will@kobble.net>"
    @content_type = 'text/plain'
    @recipients  = "#{user.email}"
    @subject     = "[k] "
    @sent_on     = Time.now
    @body[:user] = user
    @body[:account]  = Account.current
  end
end
