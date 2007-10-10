class CollectionVisibility < ActiveRecord::Migration
  def self.up
    add_column :collections, :allow_registration, :integer
    add_column :collections, :invitation, :text
    add_column :collections, :confirmation, :text
    add_column :collections, :privacy, :text
    add_column :collections, :tag, :string
    add_column :collections, :url, :string
  end

  def self.down
    remove_column :collections, :allow_registration
    remove_column :collections, :invitation
    remove_column :collections, :confirmation
    remove_column :collections, :privacy
    remove_column :collections, :tag
    remove_column :collections, :url
  end
end
