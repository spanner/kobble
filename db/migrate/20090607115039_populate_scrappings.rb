class PopulateScrappings < ActiveRecord::Migration
  def self.up
    Scrapping.reset_column_information
    Scrapping.send :is_material, :only => [:owners, :collection]

    Padding.find(:all).each do |padding|
      if padding.scratchpad && padding.scrap
        puts "* #{padding.scratchpad.created_by.name} -> #{padding.scrap.name}"
        Scrapping.create!({
          :scrap => padding.scrap, 
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
