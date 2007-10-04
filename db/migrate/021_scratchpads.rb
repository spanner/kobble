class Scratchpads < ActiveRecord::Migration
  def self.up
    create_table :scratchpads do |table|
      table.column :id, :integer
      table.column :name, :string
      table.column :user_id, :integer
    end
  end
  
  def self.down
    drop_table :scratchpads
  end
end
