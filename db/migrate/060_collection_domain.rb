class CollectionDomain < ActiveRecord::Migration
  def self.up
    add_column :collections, :url, :string
  end

  def self.down
    remove_column :collections, :url
  end
end
