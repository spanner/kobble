class CollectionPrivacy < ActiveRecord::Migration
  def self.up
    add_column :collections, :private, :boolean
    add_column :users, :trusted, :boolean
  end

  def self.down
    remove_column :collections, :private
    remove_column :users, :trusted
  end
end
