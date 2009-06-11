class Workbench < ActiveRecord::Migration
  def self.up
    rename_column :scrappings, :scrap_type, :bookmark_type
    rename_column :scrappings, :scrap_id, :bookmark_id
    rename_table :scrappings, :bookmarkings
  end

  def self.down
    rename_column :bookmarkings, :bookmark_type, :scrap_type
    rename_column :bookmarkings, :bookmark_id, :scrap_id
    rename_table :bookmarkings, :scrappings
  end
end
