class DefaultForums < ActiveRecord::Migration
  def self.up
    add_column :collections, :blogging_forum, :integer
    add_column :collections, :editorial_forum, :integer
    add_column :forums, :visibility, :integer, :default => 0
  end

  def self.down
    remove_column :collections, :blogging_forum
    remove_column :collections, :editorial_forum
    remove_column :forums, :visibility
  end
end
