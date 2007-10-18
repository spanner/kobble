class BackgroundPage < ActiveRecord::Migration
  def self.up
    add_column :collections, :background, :text
  end

  def self.down
    remove_column :collections, :background
  end
end
