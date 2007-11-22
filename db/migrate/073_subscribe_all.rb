class SubscribeAll < ActiveRecord::Migration
  def self.up
    add_column :users, :subscribe_everything, :integer
  end

  def self.down
    remove_column :users, :subscribe_everything
  end
end
