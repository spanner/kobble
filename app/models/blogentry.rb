class Blogentry < ActiveRecord::Base

  belongs_to :collection
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'

  has_one :node
  has_many :topics, :as => :subject

  after_create :create_topic

  file_column :clip
  file_column :image, :magick => { 
    :versions => { 
      "thumb" => "56x56!", 
      "slide" => "175x175!", 
      "preview" => "750x540>" 
    }
  }

  def posts_count
    topics.first.posts.count - 1
  end

  # remember collection, created_by and created_at should be filled by the edit_observer

  def create_topic
    topic = collection.blog_forum.topics.build({
      :title => name,
    })
    topic.subject = self
    logger.warn(topic.inspect)
    logger.warn("(blogentry is #{self})")
    topic.save!
    post = topic.posts.build({
      :body => "Please add your comments.",
    })
    logger.warn(post.inspect)
    post.save!
  end

end
