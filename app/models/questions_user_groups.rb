class QuestionsUserGroup < ActiveRecord::Base
  belongs_to :question
  belongs_to :user_group
end
