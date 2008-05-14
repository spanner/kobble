class CollectionPermissions < ActiveRecord::Migration

  def self.up
    create_table :permissions do |table|
      table.column :user_id, :integer
      table.column :collection_id, :integer
      table.column :admin, :boolean, :default => false
      table.column :active, :boolean, :default => false
      table.column :created_at, :datetime
      table.column :updated_at, :datetime
      table.column :created_by, :integer
      table.column :updated_by, :integer
    end
  end

  def self.down
    drop_table :permissions
  end

end
