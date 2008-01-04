class Post < ActiveRecord::Base

  acts_as_spoke
  acts_as_organised

  belongs_to :forum, :counter_cache => true
  belongs_to :topic, :counter_cache => true

  before_create { |r| r.forum_id = r.topic.forum_id }
  after_create  { |r| Topic.update_all(['replied_at = ?, replied_by = ?, last_post_id = ?', r.created_at, r.created_by, r.id], ['id = ?', r.topic_id]) }
  after_destroy { |r| t = Topic.find(r.topic_id) ; Topic.update_all(['replied_at = ?, replied_by = ?, last_post_id = ?', t.posts.last.created_at, t.posts.last.created_by, t.posts.last.id], ['id = ?', t.id]) if t.posts.last }

  validates_presence_of :body, :topic
  attr_accessible :body
  
  def editable_by?(user)
    user && (user.id == created_by || user.admin?)
  end
  
  def to_xml(options = {})
    options[:except] ||= []
    options[:except] << :topic_title << :forum_name
    super
  end
  
  def name
    "response to #{self.topic.title}"
  end
end
