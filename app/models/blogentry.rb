class Blogentry < ActiveRecord::Base

  acts_as_spoke

  has_one :node
  has_many :topics, :as => :subject

  after_create :create_topic
  
  def posts_count
    topics.first.posts.count - 1
  end

  def create_topic
    if collection.blog_forum then
      topic = collection.blog_forum.topics.build({ :title => name })
      topic.subject = self
      topic.save!
      post = topic.posts.build({ :body => 'Discussion of blog entry' })
      post.save!
    end
  end
  
end
