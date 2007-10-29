class ForumImage < ActiveRecord::Migration
  def self.up
    add_column :forums, :image, :string
  end

  def self.down
    remove_column :forums, :image
  end
end
