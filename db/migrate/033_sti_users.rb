class StiUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :type, :string, :default => 'User'
    add_column :users, :activated_at, :datetime
    add_column :users, :activation_code, :string, :limit => 40
  end

  def self.down
    remove_column :users, :type
    remove_column :users, :activated_at
    remove_column :users, :activation_code
  end
end
