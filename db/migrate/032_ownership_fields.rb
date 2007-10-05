class OwnershipFields < ActiveRecord::Migration
  def self.up
    add_column :users, :created_by, :integer
    add_column :users, :updated_by, :integer
    add_column :warnings, :created_by, :integer
    add_column :warnings, :updated_by, :integer
    add_column :warnings, :created_at, :datetime
    add_column :warnings, :updated_at, :datetime
    add_column :tags, :created_by, :integer
    add_column :tags, :updated_by, :integer
    add_column :tags, :created_at, :datetime
    add_column :tags, :updated_at, :datetime
    add_column :sources, :created_by, :integer
    add_column :sources, :updated_by, :integer
    add_column :sources, :created_at, :datetime
    add_column :sources, :updated_at, :datetime
    add_column :nodes, :created_by, :integer
    add_column :nodes, :updated_by, :integer
    add_column :nodes, :created_at, :datetime
    add_column :nodes, :updated_at, :datetime
    add_column :collections, :created_by, :integer
    add_column :collections, :updated_by, :integer
    add_column :collections, :created_at, :datetime
    add_column :collections, :updated_at, :datetime
    add_column :bundles, :created_by, :integer
    add_column :bundles, :updated_by, :integer
    add_column :bundles, :created_at, :datetime
    add_column :bundles, :updated_at, :datetime
  end

  def self.down
    remove_column :users, :created_by
    remove_column :users, :updated_by
    remove_column :warnings, :created_by
    remove_column :warnings, :updated_by
    remove_column :warnings, :created_at
    remove_column :warnings, :updated_at
    remove_column :tags, :created_by
    remove_column :tags, :updated_by
    remove_column :tags, :created_at
    remove_column :tags, :updated_at
    remove_column :sources, :created_by
    remove_column :sources, :updated_by
    remove_column :sources, :created_at
    remove_column :sources, :updated_at
    remove_column :nodes, :created_by
    remove_column :nodes, :updated_by
    remove_column :nodes, :created_at
    remove_column :nodes, :updated_at
    remove_column :collections, :created_by
    remove_column :collections, :updated_by
    remove_column :collections, :created_at
    remove_column :collections, :updated_at
    remove_column :bundles, :created_by
    remove_column :bundles, :updated_by
    remove_column :bundles, :created_at
    remove_column :bundles, :updated_at
  end
end
