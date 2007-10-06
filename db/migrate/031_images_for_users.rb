class ImagesForUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :image, :string
    add_column :users, :description, :text
    add_column :users, :honorific, :string
  end

  def self.down
    remove_column :users, :image
    remove_column :users, :description
    remove_column :users, :honorific
  end
end
