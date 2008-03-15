class Post < ActiveRecord::Base

  acts_as_spoke :except => [:illustration, :discussion, :index]

  belongs_to :topic, :counter_cache => true

  after_create  { |r| Topic.update_all(['replied_at = ?, replied_by = ?, last_post_id = ?', r.created_at, r.created_by, r.id], ['id = ?', r.topic_id]) }
  after_destroy { |r| t = Topic.find(r.topic_id) ; Topic.update_all(['replied_at = ?, replied_by = ?, last_post_id = ?', t.posts.last.created_at, t.posts.last.created_by, t.posts.last.id], ['id = ?', t.id]) if t.posts.last }

  validates_presence_of :body, :topic
  attr_accessible :body
    
  def to_xml(options = {})
    options[:except] ||= []
    options[:except] << :topic_title
    super
  end
  
  def name
    "response to #{self.topic.title}"
  end
  
  def subject_path 
    topic.subject_path
  end
end
