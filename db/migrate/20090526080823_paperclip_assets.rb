class PaperclipAssets < ActiveRecord::Migration
  def self.up
    rename_column :accounts, :image, :image_file_name
    add_column :accounts, :image_content_type, :string
    add_column :accounts, :image_file_size, :integer
    add_column :accounts, :image_updated_at, :datetime

    rename_column :accounts, :clip, :clip_file_name
    add_column :accounts, :clip_content_type, :string
    add_column :accounts, :clip_file_size, :integer
    add_column :accounts, :clip_updated_at, :datetime

    rename_column :collections, :image, :image_file_name
    add_column :collections, :image_content_type, :string
    add_column :collections, :image_file_size, :integer
    add_column :collections, :image_updated_at, :datetime

    rename_column :collections, :clip, :clip_file_name
    add_column :collections, :clip_content_type, :string
    add_column :collections, :clip_file_size, :integer
    add_column :collections, :clip_updated_at, :datetime
    
    rename_column :sources, :image, :image_file_name
    add_column :sources, :image_content_type, :string
    add_column :sources, :image_file_size, :integer
    add_column :sources, :image_updated_at, :datetime

    rename_column :sources, :clip, :clip_file_name
    add_column :sources, :clip_content_type, :string
    add_column :sources, :clip_file_size, :integer
    add_column :sources, :clip_updated_at, :datetime

    rename_column :sources, :file, :file_file_name
    add_column :sources, :file_content_type, :string
    add_column :sources, :file_file_size, :integer
    add_column :sources, :file_updated_at, :datetime

    rename_column :nodes, :image, :image_file_name
    add_column :nodes, :image_content_type, :string
    add_column :nodes, :image_file_size, :integer
    add_column :nodes, :image_updated_at, :datetime

    rename_column :nodes, :clip, :clip_file_name
    add_column :nodes, :clip_content_type, :string
    add_column :nodes, :clip_file_size, :integer
    add_column :nodes, :clip_updated_at, :datetime

    rename_column :nodes, :file, :file_file_name
    add_column :nodes, :file_content_type, :string
    add_column :nodes, :file_file_size, :integer
    add_column :nodes, :file_updated_at, :datetime
    
    rename_column :bundles, :image, :image_file_name
    add_column :bundles, :image_content_type, :string
    add_column :bundles, :image_file_size, :integer
    add_column :bundles, :image_updated_at, :datetime

    rename_column :bundles, :clip, :clip_file_name
    add_column :bundles, :clip_content_type, :string
    add_column :bundles, :clip_file_size, :integer
    add_column :bundles, :clip_updated_at, :datetime
    
    rename_column :tags, :image, :image_file_name
    add_column :tags, :image_content_type, :string
    add_column :tags, :image_file_size, :integer
    add_column :tags, :image_updated_at, :datetime

    rename_column :tags, :clip, :clip_file_name
    add_column :tags, :clip_content_type, :string
    add_column :tags, :clip_file_size, :integer
    add_column :tags, :clip_updated_at, :datetime
    
    rename_column :people, :image, :image_file_name
    add_column :people, :image_content_type, :string
    add_column :people, :image_file_size, :integer
    add_column :people, :image_updated_at, :datetime

    rename_column :people, :clip, :clip_file_name
    add_column :people, :clip_content_type, :string
    add_column :people, :clip_file_size, :integer
    add_column :people, :clip_updated_at, :datetime
    
    rename_column :occasions, :image, :image_file_name
    add_column :occasions, :image_content_type, :string
    add_column :occasions, :image_file_size, :integer
    add_column :occasions, :image_updated_at, :datetime

    rename_column :occasions, :clip, :clip_file_name
    add_column :occasions, :clip_content_type, :string
    add_column :occasions, :clip_file_size, :integer
    add_column :occasions, :clip_updated_at, :datetime
    
    rename_column :users, :image, :image_file_name
    add_column :users, :image_content_type, :string
    add_column :users, :image_file_size, :integer
    add_column :users, :image_updated_at, :datetime
    
    rename_column :users, :clip, :clip_file_name
    add_column :users, :clip_content_type, :string
    add_column :users, :clip_file_size, :integer
    add_column :users, :clip_updated_at, :datetime
  end

  def self.down
    rename_column :accounts, :image_file_name, :image
    remove_column :accounts, :image_content_type
    remove_column :accounts, :image_file_size
    remove_column :accounts, :image_updated_at

    rename_column :accounts, :clip_file_name, :clip
    remove_column :accounts, :clip_content_type
    remove_column :accounts, :clip_file_size
    remove_column :accounts, :clip_updated_at

    rename_column :collections, :image_file_name, :image
    remove_column :collections, :image_content_type
    remove_column :collections, :image_file_size
    remove_column :collections, :image_updated_at

    rename_column :collections, :clip_file_name, :clip
    remove_column :collections, :clip_content_type
    remove_column :collections, :clip_file_size
    remove_column :collections, :clip_updated_at
    
    rename_column :sources, :image_file_name, :image
    remove_column :sources, :image_content_type
    remove_column :sources, :image_file_size
    remove_column :sources, :image_updated_at

    rename_column :sources, :clip_file_name, :clip
    remove_column :sources, :clip_content_type
    remove_column :sources, :clip_file_size
    remove_column :sources, :clip_updated_at

    rename_column :sources, :file_file_name, :file
    remove_column :sources, :file_content_type
    remove_column :sources, :file_file_size
    remove_column :sources, :file_updated_at

    rename_column :nodes, :image_file_name, :image
    remove_column :nodes, :image_content_type
    remove_column :nodes, :image_file_size
    remove_column :nodes, :image_updated_at

    rename_column :nodes, :clip_file_name, :clip
    remove_column :nodes, :clip_content_type
    remove_column :nodes, :clip_file_size
    remove_column :nodes, :clip_updated_at

    rename_column :nodes, :file_file_name, :file
    remove_column :nodes, :file_content_type
    remove_column :nodes, :file_file_size
    remove_column :nodes, :file_updated_at
    
    rename_column :bundles, :image_file_name, :image
    remove_column :bundles, :image_content_type
    remove_column :bundles, :image_file_size
    remove_column :bundles, :image_updated_at

    rename_column :bundles, :clip_file_name, :clip
    remove_column :bundles, :clip_content_type
    remove_column :bundles, :clip_file_size
    remove_column :bundles, :clip_updated_at
    
    rename_column :tags, :image_file_name, :image
    remove_column :tags, :image_content_type
    remove_column :tags, :image_file_size
    remove_column :tags, :image_updated_at

    rename_column :tags, :clip_file_name, :clip
    remove_column :tags, :clip_content_type
    remove_column :tags, :clip_file_size
    remove_column :tags, :clip_updated_at
    
    rename_column :people, :image_file_name, :image
    remove_column :people, :image_content_type
    remove_column :people, :image_file_size
    remove_column :people, :image_updated_at

    rename_column :people, :clip_file_name, :clip
    remove_column :people, :clip_content_type
    remove_column :people, :clip_file_size
    remove_column :people, :clip_updated_at
    
    rename_column :occasions, :image_file_name, :image
    remove_column :occasions, :image_content_type
    remove_column :occasions, :image_file_size
    remove_column :occasions, :image_updated_at

    rename_column :occasions, :clip_file_name, :clip
    remove_column :occasions, :clip_content_type
    remove_column :occasions, :clip_file_size
    remove_column :occasions, :clip_updated_at
    
    rename_column :users, :image_file_name, :image
    remove_column :users, :image_content_type
    remove_column :users, :image_file_size
    remove_column :users, :image_updated_at
    
    rename_column :users, :clip_file_name, :clip
    remove_column :users, :clip_content_type
    remove_column :users, :clip_file_size
    remove_column :users, :clip_updated_at
  end
end
