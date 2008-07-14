class MoreIndexes < ActiveRecord::Migration
  def self.up
    add_index :users, :email, :unique => true
    add_index :users, :account_id
    add_index :collections, :account_id
    add_index :events, :at
    add_index :events, :user_id
    add_index :events, [:affected_type, :affected_id]
    add_index :annotations, [:annotated_type, :annotated_id]
    add_index :annotations, :annotation_type_id
    add_index :tags, :name                                    # for inline tag completer
    add_index :taggings, [:taggable_type, :taggable_id]
    add_index :taggings, :collection_id                       # for cloud-building
    add_index :user_preferences, :user_id
    add_index :activations, [:user_id, :active]
    add_index :activations, :collection_id
    add_index :permissions, [:user_id, :active]
    add_index :permissions, :collection_id
    add_index :monitorships, [:topic_id, :active]             # monitorships are usually called when a reply is posted
    add_index :monitorships, :user_id
    add_index :occasions, :collection_id
    add_index :sources, :speaker_id
    add_index :nodes, :speaker_id
    
    # for the display of user pages
    # and the .latest named_scope
    
    [:nodes, :sources, :bundles, :people, :tags, :topics, :occasions, :scratchpads].each do |table|
      add_index table, :created_by
      add_index table, :created_at
    end
  
    # this will only really matter if there are lots of deleted items
    # but it should help with general queries if mysql manages to merge the indexes
      
    [:collections, :users, :nodes, :sources, :occasions, :bundles, :bundlings, :people, :tags, :taggings, :topics, :posts, :scratchpads, :paddings, :annotations, :activations, :monitorships].each do |table|
      add_index table, :deleted_at
    end
  end

  def self.down
    remove_index :users, :column => :email
    remove_index :users, :column => :account_id
    remove_index :collections, :column => :account_id
    remove_index :events, :column => :at
    remove_index :events, :column => :user_id
    remove_index :events, :column => [:affected_type, :affected_id]
    remove_index :annotations, :column => [:annotated_type, :annotated_id]
    remove_index :annotations, :column => :annotation_type_id
    remove_index :taggings, :column => [:taggable_type, :taggable_id]
    remove_index :taggings, :column => :collection_id
    remove_index :user_preferences, :column => :user_id
    remove_index :activations, :column => :user_id
    remove_index :activations, :column => :collection_id
    remove_index :permissions, :column => :user_id
    remove_index :permissions, :column => :collection_id
    remove_index :monitorships, :column => :user_id
    remove_index :monitorships, :column => :topic_id
    remove_index :occasions, :column => :collection_id
    
    [:nodes, :sources, :bundles, :people, :tags, :topics, :occasions].each do |table|
      remove_index table, :column => :created_by
      remove_index table, :column => :created_at
    end
      
    [:collections, :users, :nodes, :sources, :occasions, :bundles, :bundlings, :people, :tags, :taggings, :topics, :posts, :scratchpads, :paddings, :annotations, :activations, :monitorships].each do |table|
      remove_index table, :column => :deleted_at
    end
  end
end
