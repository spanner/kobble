class Makespeakers < ActiveRecord::Migration
  def self.up
    rename_column :sources, :user_id, :speaker_id
    rename_column :nodes, :user_id, :speaker_id
  end

  def self.down
    rename_column :sources, :speaker_id, :user_id
    rename_column :nodes, :speaker_id, :user_id
  end
end
