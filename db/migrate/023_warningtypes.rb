class Warningtypes < ActiveRecord::Migration
    def self.up
      create_table :warningtypes do |table|
        table.column :id, :integer
        table.column :name, :string
        table.column :prevents_use, :integer
      end
    end

    def self.down
      drop_table :warningtypes
    end
  end
