class TaggingsHaveCollections < ActiveRecord::Migration
  def self.up
    add_column :taggings, :collection_id, :integer
    remove_index :taggings, :name => :index_tag_marks
    add_index :taggings, :tag_id, :name => 'by_tag'
    add_index :taggings, :collection_id, :name => 'by_collection'
    
    Tagging.reset_column_information
    Tagging.find(:all).select { |tagging| tagging.taggable.nil? }.each{|tagging| tagging.destroy }
    Tagging.find(:all).each do |tagging| 
      tagging.collection = tagging.taggable.collection
      tagging.save!
    end
  end

  def self.down
    remove_column :taggings, :collection_id
    remove_index :taggings, :tag_id
  end
end
