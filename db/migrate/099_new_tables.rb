class NewTables < ActiveRecord::Migration

  def self.up
    create_table :permissions do |table|
      table.column :user_id, :integer
      table.column :collection_id, :integer
      table.column :admin, :boolean, :default => false
      table.column :active, :boolean, :default => false
      table.column :created_at, :datetime
      table.column :updated_at, :datetime
      table.column :created_by, :integer
      table.column :updated_by, :integer
    end
    
    create_table :account_types do |table|
      table.column :name, :string
      table.column :description, :string
      table.column :price_monthly, :float
      table.column :price_yearly, :float
      table.column :collections_limit, :integer
      table.column :users_limit, :integer
      table.column :sources_limit, :integer
      table.column :space_limit, :integer, :default => 0
      table.column :can_audio, :boolean
      table.column :can_video, :boolean
      table.column :can_rss, :boolean
      table.column :created_at, :datetime
      table.column :updated_at, :datetime
      table.column :created_by, :integer
      table.column :updated_by, :integer
    end

    create_table :events do |table|
      table.column :affected_id, :integer
      table.column :affected_type, :string
      table.column :affected_name, :string
      table.column :event_type, :string
      table.column :account_id, :integer
      table.column :collection_id, :integer
      table.column :user_id, :integer
      table.column :notes, :text
      table.column :at, :datetime
    end
    
    create_table :annotations do |table|
      table.column :annotated_id, :integer
      table.column :annotated_type, :string
      table.column :annotation_type_id, :integer
      table.column :body, :text
      table.column :created_by, :integer
      table.column :updated_by, :integer
      table.column :created_at, :datetime
      table.column :updated_at, :datetime
    end
    
    create_table :annotation_types do |table|
      table.column :name, :string
      table.column :description, :text
      table.column :created_by, :integer
      table.column :updated_by, :integer
      table.column :created_at, :datetime
      table.column :updated_at, :datetime
    end
    
    [:collections, :sources, :nodes, :bundles, :bundlings, :topics, :monitorships, :posts, :tags, :taggings, :flags, :flaggings, :users, :people, :occasions].each do |table|
      add_column table, :deleted_at, :datetime
    end
   
  end

  def self.down
    drop_table :permissions
    drop_table :account_types
    drop_table :event_log
    drop_table :annotations
    drop_table :annotation_types

    [:collections, :sources, :nodes, :bundles, :bundlings, :topics, :monitorships, :posts, :tags, :taggings, :flags, :flaggings, :users, :people, :occasions].each do |table|
      remove_column table, :deleted_at
    end

  end

end
