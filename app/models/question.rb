class Question < ActiveRecord::Base

  belongs_to :collection
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  belongs_to :survey
  belongs_to :user_group      

  has_many :nodes, :dependent => :nullify
  has_many :answers, :dependent => :destroy
  has_many :topics, :as => :subject

  file_column :clip
  file_column :image, :magick => { 
    :versions => { 
      "thumb" => "56x56!", 
      "slide" => "135x135!", 
      "preview" => "750x540>" 
    }
  }
  
  def summary
    description = ''
    case self.question_type
    when "multi"
      description = "Multiple-choice question with #{pluralize(self.options.length, 'option')}."
    when "scale"
      description = "Scale question running from #{self.scalemin} to #{self.scalemax}."
    when "binary"
      description = "Yes/no question."
    when "numeric"
      description = "Numeric question (we'll check that the answer is a number)."
    when "text"
      description = "Free-text question."
    end
  end
  
  def options
    self.prompt.split('|')
  end
  
  def scalemin
    self.options[0]
  end

  def scalemax
    self.options[1]
  end
  
  def answer_from(user)
    Answer.find(:first, :conditions => ['created_by = ? and question_id = ?', user.id, self.id])
  end

  def tag_list
    tags.map {|t| t.name }.uniq.join(', ')
  end

end
