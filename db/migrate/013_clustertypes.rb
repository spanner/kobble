class Clustertypes < ActiveRecord::Migration
  def self.up
    create_table :clustertypes do |table|
      table.column :id, :integer
      table.column :name, :string
      table.column :ordered, :integer
    end
  end

  def self.down
    drop_table :clustertypes
  end
end
