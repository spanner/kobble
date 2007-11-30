class UserGroupNotifier < ActionMailer::Base
  def message (user, group, collection, title, message)
    setup_email(user, group, collection)
    @subject += title
    @body[:code]  = user.activation_code
    @body[:message] = message
  end

  protected
  def setup_email(user, group, collection)
    @content_type = 'text/plain'
    @recipients  = "#{user.email}"
    @from        = "#{collection.email_from}"
    @subject     = "[#{collection.abbreviation}] "
    @sent_on     = Time.now
    @body[:user] = user
    @body[:collection] = collection
    @body[:group] = group
  end
end
