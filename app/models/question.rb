class Question < ActiveRecord::Base

  belongs_to :collection
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  belongs_to :survey
  belongs_to :user_group      

  has_many :nodes
  # acts_as_list :scope => :collection 
  after_create :create_topic
  
  def name
    prompt
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
