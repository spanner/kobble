class QuestionObserver < ActiveRecord::Observer
    
  def after_create(question)
    if (question.send_email != "0")
      users = users_for(question)
      users.each do |user|
        UserNotifier.deliver_question_notification(user, question)
      end
    end
    question.send_email = "0"
  end

  def after_update(question)
    if (question.send_email != "0")
      users = users_for(question)
      users.each do |user|
        UserNotifier.deliver_question_notification(user, question)
      end
    end
    question.send_email = "0"
  end

  def users_for(question)
    users = question.user_group ? 
      User.find(:all, :conditions => ["users.collection_id = ? and users.receive_questions_email > 0 and (users.user_group = ? OR users.user_group_id is NULL)", Collection.current_collection, question.user_group]) :
      User.find(:all, :conditions => ["users.collection_id = ? and users.receive_questions_email > 0", Collection.current_collection])
  end

end
