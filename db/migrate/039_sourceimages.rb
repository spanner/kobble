class Sourceimages < ActiveRecord::Migration
  def self.up
    add_column :sources, :image, :string
  end

  def self.down
    remove_column :sources, :image
  end
end
