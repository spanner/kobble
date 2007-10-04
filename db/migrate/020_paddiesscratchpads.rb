class Paddiesscratchpads < ActiveRecord::Migration
    def self.up
      create_table :paddies_scratchpads do |table|
        table.column :scratchpad_id, :integer
        table.column :paddy_type, :string, :limit => 20
        table.column :paddy_id, :integer
      end
    end

    def self.down
      drop_table :paddies_scratchpads
    end
  end
