class Keywords < ActiveRecord::Migration
  def self.up
    create_table :keywords do |table|
      table.column :parent_id, :integer
      table.column :name, :string
      table.column :description, :text
      table.column :colour, :string, :limit => 7
      table.column :nodes_count, :integer
    end
  end

  def self.down
  end
end
