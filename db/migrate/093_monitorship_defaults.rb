class MonitorshipDefaults < ActiveRecord::Migration

  # we now create a monitorship object on first encounter with a topic, so it needs to default to inactive

  def self.up
    change_column :monitorships, :active, :boolean, :default => 0
  end

  def self.down
    change_column :monitorships, :active, :boolean, :default => 1
  end
end
