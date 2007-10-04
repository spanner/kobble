class People < ActiveRecord::Migration
  def self.up
    create_table :people do |table|
      table.column :id, :integer
      table.column :name, :string
      table.column :image, :string
      table.column :description, :text
      table.column :notes, :text
      table.column :node_count, :integer
    end
  end
  
  def self.down
    drop_table :people
  end
end
