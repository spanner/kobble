class UserNotifier < ActionMailer::Base
  
  def activation(user)
    setup_email(user, collection)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "#{collection.url}/account"
  end

  def newpassword(user)
    setup_email(user, collection)
    @subject    += 'Your provisional new password'
    @body[:url]  = "http://#{collection.url}/account/fixpassword/#{user.activation_code}"
    @body[:code]  = user.activation_code
    @body[:password]  = user.new_password
  end

  def post(user, post)
    collection = Collection.current_collection
    setup_email(user, collection)
    @subject    += "New comment under '#{post.topic.title}'"
    @body[:post]  = post
    @body[:url]  = "http://#{collection.url}/topics/#{post.topic_id}##{post.id}"
    @body[:prefsurl]  = "http://#{collection.url}/me"
  end
  
  def welcome(user, inviter)
    
    
  end

  protected
  def setup_email(user, inviter)
    # @content_type = user.receive_html_email ? 'text/html' : 'text/plain'
    @content_type = 'text/plain'
    @recipients  = "#{user.email}"
    @from        = "#{collection.email_from}"
    @subject     = "[#{collection.abbreviation}] "
    @sent_on     = Time.now
    @body[:user] = user
    @body[:collection] = collection
  end
end
