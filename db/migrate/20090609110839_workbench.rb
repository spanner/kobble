class Workbench < ActiveRecord::Migration
  def self.up
    rename_column :scrappings, :scrap_type, :benched_type
    rename_column :scrappings, :scrap_id, :benched_id
    rename_table :scrappings, :benchings
  end

  def self.down
    rename_column :benchings, :benched_type, :scrap_type
    rename_column :benchings, :benched_id, :scrap_id
    rename_table :benchings, :scrappings
  end
end
