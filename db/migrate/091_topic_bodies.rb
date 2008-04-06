class TopicBodies < ActiveRecord::Migration

  def self.up
    Topic.find(:all, :conditions => ['referent_type = ?', 'Blogentry']).each { |topic| topic.destroy }
    Topic.find(:all, :conditions => 'referent_type is NULL').each { |topic| topic.destroy }
    Topic.find(:all).each do |topic|
      post = topic.posts.first
      if post
        topic.body = post.body
        topic.posts.delete(post)
      else
        topic.destroy
      end
    end
  end

  def self.down
  end
end
