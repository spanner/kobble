class TagsCollectable < ActiveRecord::Migration
  def self.up
    add_column :tags, :collection_id, :integer
  end

  def self.down
    remove_column :tags, :collection_id
  end
    
end
