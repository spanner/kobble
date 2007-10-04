class Collections < ActiveRecord::Migration
  def self.up
    create_table :collections do |table|
      table.column :user_id, :integer
      table.column :name, :string
      table.column :description, :text, :default => ''
      table.column :status, :string
    end

    create_table :collections_users do |table|
      table.column :user_id, :integer
      table.column :collection_id, :integer
      table.column :status, :string
    end

    add_column :sources, :collection_id, :integer
    add_column :people, :collection_id, :integer
    add_column :nodes, :collection_id, :integer
    add_column :bundles, :collection_id, :integer
  end

  def self.down
    drop_table :collections
    drop_table :collections_users
    remove_column :sources, :collection_id
    remove_column :people, :collection_id
    remove_column :nodes, :collection_id
    remove_column :bundles, :collection_id
  end
end
