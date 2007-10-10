class CollectionWelcome < ActiveRecord::Migration
  def self.up
    rename_column :collections, :confirmation, :welcome
  end

  def self.down
    rename_column :collections, :welcome, :confirmation
  end
end
