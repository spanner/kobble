class MultipleActiveCollections < ActiveRecord::Migration
  def self.up
    create_table :collection_users do |table|
      table.column :collection_id, :integer
      table.column :user_id, :integer
      table.column :active, :integer
    end    
  end

  def self.down
    drop_table :collection_users
  end
end
