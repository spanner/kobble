class UserCollection < ActiveRecord::Migration
  def self.up
    add_column :users, :collection_id, :integer
  end

  def self.down
    remove_column :users, :collection_id
  end
end
