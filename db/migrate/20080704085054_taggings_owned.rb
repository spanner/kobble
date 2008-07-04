class TaggingsOwned < ActiveRecord::Migration
  def self.up
    add_column :taggings, :created_by, :integer
    add_column :taggings, :updated_by, :integer
    add_column :taggings, :created_at, :datetime
    add_column :taggings, :updated_at, :datetime
    
    puts "-- Assigning owners to taggings based on tagged item"
    Tagging.reset_column_information
    Tagging.find(:all).each do |ting|
      if (ting.taggable.nil?)
        ting.destroy
      else
        ting.created_by = ting.taggable.created_by
        ting.created_at = ting.taggable.created_at
        ting.save
      end
    end
  end

  def self.down
    remove_column :taggings, :created_by
    remove_column :taggings, :updated_by
    remove_column :taggings, :created_at
    remove_column :taggings, :updated_at
  end
end
