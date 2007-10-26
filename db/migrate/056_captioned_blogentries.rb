class CaptionedBlogentries < ActiveRecord::Migration
  def self.up
    add_column :blogentries, :caption, :string
  end

  def self.down
    remove_column :blogentries, :caption
  end
end
