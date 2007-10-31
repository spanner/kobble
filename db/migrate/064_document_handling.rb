class DocumentHandling < ActiveRecord::Migration
  def self.up
    add_column :sources, :file, :string
  end

  def self.down
    remove_column :sources, :file
  end
end
