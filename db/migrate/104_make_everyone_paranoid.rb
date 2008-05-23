class MakeEveryoneParanoid < ActiveRecord::Migration
  def self.up
    [:collections, :sources, :nodes, :bundles, :bundlings, :topics, :monitorships, :posts, :tags, :taggings, :flags, :flaggings, :users, :people, :occasions].each do |table|
      add_column table, :deleted_at, :datetime
    end
  end

  def self.down
    [:collections, :sources, :nodes, :bundles, :bundlings, :topics, :monitorships, :posts, :tags, :taggings, :flags, :flaggings, :users, :people, :occasions].each do |table|
      remove_column table, :deleted_at
    end
  end
end
