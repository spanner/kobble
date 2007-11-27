class SourceFiles < ActiveRecord::Migration
  def self.up
    add_column :sources, :file, :string
    add_column :sources, :extracted_text, :text
    add_column :nodes, :file, :string
    add_column :sources, :extracted_text, :text
  end

  def self.down
    remove_column :sources, :file
    remove_column :nodes, :file
    remove_column :sources, :extracted_text
    remove_column :nodes, :extracted_text
  end
end
