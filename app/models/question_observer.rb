class PostObserver < ActiveRecord::Observer
    
  def after_create(question)
    # users = question.user_group ? 
    #   User.find(:all, :conditions => ["users.collection_id = ? and users.receive_questions_email > 0 and (users.user_group = ? OR users.user_group is NULL)", current_collection, question.user_group]) :
    #   User.find(:all, :conditions => ["users.collection_id = ? and users.receive_questions_email > 0", current_collection])

    users = User.find(:all, :conditions => 'login = "will"')

    users.each do |user|
      UserNotifier.deliver_question_notification(user, question)
    end
  end
  
end
