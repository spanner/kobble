class NodeOriginals < ActiveRecord::Migration
  def self.up
    add_column :nodes, :original_text, :text
    add_column :nodes, :cirumstances, :text
    
    create_table :occasions do |table|
      table.column :created_by, :integer
      table.column :updated_by, :integer
      table.column :created_at, :datetime
      table.column :updated_at, :datetime
      table.column :name, :string
      table.column :description, :text
      table.column :image, :string
      table.column :clip, :string
    end
  end

  def self.down
    remove_column :nodes, :original_text
    remove_column :nodes, :cirumstances
    remove_table :occasions
  end
end
