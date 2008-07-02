class MoreUndelete < ActiveRecord::Migration
  def self.up
    add_column :paddings, :deleted_at, :datetime
    add_column :activations, :deleted_at, :datetime
    add_column :permissions, :deleted_at, :datetime
    add_column :account_types, :deleted_at, :datetime
    add_column :annotation_types, :deleted_at, :datetime
  end

  def self.down
    remove_column :paddings, :deleted_at
    remove_column :activations, :deleted_at
    remove_column :permissions, :deleted_at
    remove_column :account_types, :deleted_at
    remove_column :annotation_types, :deleted_at
  end
end
