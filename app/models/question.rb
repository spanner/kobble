class Question < ActiveRecord::Base

  belongs_to :collection
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  belongs_to :survey
  belongs_to :user_group      

  has_many :nodes
  acts_as_list :scope => :survey 
  after_create :create_topic

  def create_topic
    if collection.blog_forum then
      topic = collection.blog_forum.topics.build({ :title => prompt })
      topic.subject = self
      topic.save!
      post = topic.posts.build({ :body => 'Discussion of survey question' })
      post.save!
    end
  end

end
