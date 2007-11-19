class Question < ActiveRecord::Base

  belongs_to :collection
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  belongs_to :survey
  belongs_to :user_group      

  has_many :nodes, :dependent => :nullify
  has_many :topics, :as => :subject

  file_column :clip
  file_column :image, :magick => { 
    :versions => { 
      "thumb" => "56x56!", 
      "slide" => "135x135!", 
      "preview" => "750x540>" 
    }
  }

  after_create :create_topic
  
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
    description += " Image allowed." if self.request_image
    description += " Clip allowed." if self.request_clip
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
    Node.find(:first, :conditions => ['created_by = ? and question_id = ?', user.id, self.id])
  end

  def create_topic
    if collection.blog_forum then
      topic = collection.blog_forum.topics.build({ :title => prompt })
      topic.subject = self
      topic.save!
      post = topic.posts.build({ :body => 'Discussion of survey question' })
      post.save!
    end
  end

  def tag_list
    tags.map {|t| t.name }.uniq.join(', ')
  end

end
