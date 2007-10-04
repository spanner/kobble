class PolymorphicWarnings < ActiveRecord::Migration
  def self.up
    create_table :offenders_warnings do |table|
      table.column :warning_id, :integer
      table.column :offender_type, :string, :limit => 20
      table.column :offender_id, :integer
    end
    
  #import existing taggings from old warning link tables...
    
  end

  def self.down
    drop_table :offenders_warnings
  end
end
