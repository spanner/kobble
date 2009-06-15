class PopulateBookmarks < ActiveRecord::Migration
  def self.up
    Bookmarking.reset_column_information
    Bookmarking.send :is_material, :only => [:owners, :collection]

    Padding.find(:all).each do |padding|
      if padding.scratchpad && padding.scrap
        puts "* #{padding.scratchpad.created_by.name} -> #{padding.scrap.name}"
        Bookmarking.create!({
          :bookmark => padding.scrap, 
          :created_by => padding.scratchpad.created_by,
          :created_at => padding.scratchpad.created_at,
          :collection => padding.scrap.collection,
        })
      end
    end
  end

  def self.down
  end
end
