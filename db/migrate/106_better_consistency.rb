class BetterConsistency < ActiveRecord::Migration
  def self.up
    add_column :tags, :circumstances, :text
    add_column :tags, :clip, :string
    add_column :people, :circumstances, :text
    add_column :bundles, :circumstances, :text
    add_column :bundles, :clip, :string
    add_column :collections, :image, :string
    add_column :collections, :clip, :string
    add_column :users, :clip, :string
  end

  def self.down
    remove_column :tags, :circumstances
    remove_column :tags, :clip
    remove_column :people, :circumstances
    remove_column :bundles, :circumstances
    remove_column :bundles, :clip
    remove_column :collections, :image
    remove_column :collections, :clip
    remove_column :users, :clip
  end
end
