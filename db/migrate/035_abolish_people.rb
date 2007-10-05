class AbolishPeople < ActiveRecord::Migration
  def self.up
    remove_column :nodes, :person_id
    remove_column :sources, :person_id
    drop_table :nodes_people
    drop_table :people
    drop_table :helptexts
    drop_table :bundletypes
    drop_table :warningtypes
  end

  def self.down
  end
end
