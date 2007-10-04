class Keywordsnodes < ActiveRecord::Migration
  def self.up
    create_table :keywords_nodes do |table|
      table.column :node_id, :integer
      table.column :keyword_id, :integer
    end
  end

  def self.down
    drop_table :keywords_nodes
  end
end
