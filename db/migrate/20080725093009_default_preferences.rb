class DefaultPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :default_true, :boolean
  end

  def self.down
    remove_column :preferences, :default_true
  end
end
