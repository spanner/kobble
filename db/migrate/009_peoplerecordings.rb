class Peoplerecordings < ActiveRecord::Migration
  def self.up
    create_table :people_recordings do |table|
      table.column :person_id, :integer
      table.column :recording_id, :integer
    end
  end

  def self.down
    drop_table :people_recordings
  end
end
