class Bundleimages < ActiveRecord::Migration
  def self.up
    add_column :bundles, :image, :string
    add_column :bundles, :position, :integer
  end

  def self.down
    remove_column :bundles, :image
    remove_column :bundles, :position
  end
end
