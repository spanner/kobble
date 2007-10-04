class Keywordsrecordings < ActiveRecord::Migration
  def self.up
    create_table :keywords_recordings do |table|
      table.column :recording_id, :integer
      table.column :keyword_id, :integer
    end
  end

  def self.down
    drop_table :keywords_recordings
  end
end
