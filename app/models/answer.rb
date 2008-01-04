class Answer < ActiveRecord::Base

  acts_as_spoke
  acts_as_organised
  acts_as_illustrated

  belongs_to :speaker, :class_name => 'User', :foreign_key => 'speaker_id'
  belongs_to :question
  validates_presence_of :body

  def name
    "response to #{self.question.name} from #{self.speaker.name}"
  end

end
