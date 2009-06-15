class NodeFiles < ActiveRecord::Migration
  def self.up
    add_column :nodes, :file_from, :string, :default => 'source'
    Node.reset_column_information
    Node.find(:all).each do |node|
      node.file_from = node.has_file? ? 'file' : 'source'
      node.save
    end
  end

  def self.down
    remove_column :nodes, :file_from
  end
end
