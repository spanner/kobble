class IllustrateTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :image, :string
  end

  def self.down
    remove_column :tags, :image
  end
end
