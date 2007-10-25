class CollectionAbbreviation < ActiveRecord::Migration
  def self.up
    rename_column :collections, :tag, :abbreviation
  end

  def self.down
    rename_column :collections, :abbreviation, :tag
  end
end
