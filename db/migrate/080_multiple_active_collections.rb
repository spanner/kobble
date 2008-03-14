class MultipleActiveCollections < ActiveRecord::Migration
  def self.up
    create_table :activations do |table|
      table.column :collection_id, :integer
      table.column :user_id, :integer
      table.column :active, :boolean, :default => true
    end    
  end

  def self.down
    drop_table :activations
  end
end
