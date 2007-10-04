class Warnings < ActiveRecord::Migration
    def self.up
      create_table :warnings do |table|
        table.column :id, :integer
        table.column :body, :text
        table.column :offender_type, :string, :limit => 20
        table.column :offender_id, :integer
        table.column :user_id, :integer
        table.column :warningtype_id, :string
      end
    end

    def self.down
      drop_table :warnings
    end
  end
