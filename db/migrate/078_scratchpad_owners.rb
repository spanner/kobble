class ScratchpadOwners < ActiveRecord::Migration
  def self.up
    rename_column :scratchpads, :user_id, :created_by
    add_column :scratchpads, :created_at, :datetime
    add_column :scratchpads, :updated_by, :integer
    add_column :scratchpads, :updated_at, :datetime
    add_column :scratchpads, :collection_id, :integer
  end

  def self.down
    rename_column :scratchpads, :created_by, :user_id
    remove_column :scratchpads, :created_at
    remove_column :scratchpads, :updated_by
    remove_column :scratchpads, :updated_at
    remove_column :scratchpads, :collection_id
  end
end
