class StripClips < ActiveRecord::Migration
  def self.up
    remove_column :sources, :clip_file_name
    remove_column :sources, :clip_content_type
    remove_column :sources, :clip_file_size
    remove_column :sources, :clip_updated_at
    
    remove_column :nodes, :clip_file_name
    remove_column :nodes, :clip_content_type
    remove_column :nodes, :clip_file_size
    remove_column :nodes, :clip_updated_at

    remove_column :accounts, :clip_file_name
    remove_column :accounts, :clip_content_type
    remove_column :accounts, :clip_file_size
    remove_column :accounts, :clip_updated_at
    
    remove_column :bundles, :clip_file_name
    remove_column :bundles, :clip_content_type
    remove_column :bundles, :clip_file_size
    remove_column :bundles, :clip_updated_at
    
    remove_column :collections, :clip_file_name
    remove_column :collections, :clip_content_type
    remove_column :collections, :clip_file_size
    remove_column :collections, :clip_updated_at
    
    remove_column :occasions, :clip_file_name
    remove_column :occasions, :clip_content_type
    remove_column :occasions, :clip_file_size
    remove_column :occasions, :clip_updated_at
    remove_column :occasions, :image_file_name
    remove_column :occasions, :image_content_type
    remove_column :occasions, :image_file_size
    remove_column :occasions, :image_updated_at
    
    remove_column :people, :clip_file_name
    remove_column :people, :clip_content_type
    remove_column :people, :clip_file_size
    remove_column :people, :clip_updated_at
    
    remove_column :tags, :clip_file_name
    remove_column :tags, :clip_content_type
    remove_column :tags, :clip_file_size
    remove_column :tags, :clip_updated_at
    remove_column :tags, :image_file_name
    remove_column :tags, :image_content_type
    remove_column :tags, :image_file_size
    remove_column :tags, :image_updated_at
    
    remove_column :users, :clip_file_name
    remove_column :users, :clip_content_type
    remove_column :users, :clip_file_size
    remove_column :users, :clip_updated_at
    remove_column :users, :image_file_name
    remove_column :users, :image_content_type
    remove_column :users, :image_file_size
    remove_column :users, :image_updated_at
  end

  def self.down
  end
end
