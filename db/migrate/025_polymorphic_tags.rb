class PolymorphicTags < ActiveRecord::Migration
  def self.up
    create_table :marks_tags do |table|
      table.column :tag_id, :integer
      table.column :mark_type, :string, :limit => 20
      table.column :mark_id, :integer
    end
    
  #import existing taggings from old keyword link tables...
  
  end

  def self.down
    drop_table :marks_tags
  end
end
