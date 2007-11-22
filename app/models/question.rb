class Question < ActiveRecord::Base

  belongs_to :collection
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  belongs_to :survey

  has_and_belongs_to_many :user_groups     

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
  
  attr_accessor :send_email
  
  def summary
    description = ''
    case self.question_type
    when "multi"
      description = "Multiple-choice question with #{pluralize(self.options.length, 'option')}."
    when "scale"
      description = "Scale question running from '#{self.scalemin}' to '#{self.scalemax}'."
    when "binary"
      description = "Yes/no question."
    when "numeric"
      description = "Numeric question."
    when "text"
      description = "Free-text question."
    end
  end
  
  def options
    if (self.question_type == 'text' || self.question_type == 'number')
      return ()
    elsif (self.question_type == 'scale')
      return (1..8)
    else
      self.prompt.split('|')
    end
  end
  
  def scalemin
    self.prompt.split('|')[0]
  end

  def scalemax
    self.prompt.split('|')[1]
  end
  
  def collected_responses
    responses = {}
    responses[:max] = 0
    self.options.each { |o| responses[o.to_s] = 0 }
    self.answers.each do |a| 
      responses[a.body].nil? ? responses[a.body] = 1 : responses[a.body] += 1 
      responses[:max] = responses[a.body] if responses[a.body] > responses[:max]
    end
    responses
  end
    
  def answer_from(user)
    Answer.find(:first, :conditions => ['created_by = ? and question_id = ?', user.id, self.id])
  end

  def tag_list
    tags.map {|t| t.name }.uniq.join(', ')
  end

end
