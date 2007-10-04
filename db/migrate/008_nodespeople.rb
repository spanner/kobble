class Nodespeople < ActiveRecord::Migration
  def self.up
    create_table :nodes_people do |table|
      table.column :person_id, :integer
      table.column :node_id, :integer
    end
  end

  def self.down
    drop_table :nodes_people
  end
end
