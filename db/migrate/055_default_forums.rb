class DefaultForums < ActiveRecord::Migration
  def self.up
    add_column :collections, :blog_forum_id, :integer
    add_column :collections, :editorial_forum_id, :integer
    add_column :forums, :visibility, :integer, :default => 0
  end

  def self.down
    remove_column :collections, :blog_forum_id
    remove_column :collections, :editorial_forum_id
    remove_column :forums, :visibility
  end
end
