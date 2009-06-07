class ClarifyOwnership < ActiveRecord::Migration
  def self.up
    [:account_types, :users, :accounts, :collections, :sources, :nodes, :bundles, :tags, :taggings, :users, :occasions, :scratchpads, :permissions, :topics, :posts, :annotation_types, :annotations, :preferences].each do |table|
      rename_column table, :created_by, :created_by_id
    end
  end

  def self.down
    [:account_types, :users, :accounts, :collections, :sources, :nodes, :bundles, :tags, :taggings, :users, :occasions, :scratchpads, :permissions, :topics, :posts, :annotation_types, :annotations, :preferences].each do |table|
      rename_column table, :created_by_id, :created_by
    end
  end
end
