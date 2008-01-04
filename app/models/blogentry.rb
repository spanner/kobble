class Blogentry < ActiveRecord::Base

  acts_as_spoke
  acts_as_organised
  acts_as_illustrated

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

  def has_body?
    !self.body.nil? and self.body.length != 0
  end

  def has_image?
    !self.image.nil?# and File.file? self.image
  end

  def has_clip?
    !self.clip.nil?# and File.file? self.clip
  end

  def has_node?
    !self.node.nil?
  end
  
end
