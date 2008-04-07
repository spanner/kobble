class TagBodies < ActiveRecord::Migration

  def self.up
    add_column :tags, :body, :text
    Tag.reset_column_information
    Tag.find(:all).each do |tag| 
      tag.body = tag.description; 
      tag.description = nil
      tag.save
    end
  end

  def self.down
    remove_column :tags, :body
  end
end
