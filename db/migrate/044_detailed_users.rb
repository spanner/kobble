class DetailedUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :workplace, :string
    change_column :users, :role, :string, :limit => 255
    add_column :users, :phone, :string
  end

  def self.down
    remove_column :users, :workplace
    change_column :users, :role, :string, :limit => 40
    remove_column :users, :phone
  end
end
