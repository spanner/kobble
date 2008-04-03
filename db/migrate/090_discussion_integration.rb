class DiscussionIntegration < ActiveRecord::Migration

  def self.up
    remove_column :posts, :body_html
    add_column :topics, :body, :text
  end

  def self.down
    add_column :posts, :body_html, :text
    remove_column :topics, :body
  end
end
