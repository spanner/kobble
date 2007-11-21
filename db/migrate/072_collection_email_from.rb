class CollectionEmailFrom < ActiveRecord::Migration
  def self.up
    add_column :collections, :email_from, :string
  end

  def self.down
    remove_column :collections, :email_from
  end
end
