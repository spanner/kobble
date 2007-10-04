class Clusters < ActiveRecord::Migration
  def self.up
    create_table :clusters do |table|
      table.column :id, :integer
      table.column :name, :string
      table.column :body, :text
      table.column :user_id, :integer
      table.column :clustertype_id, :integer
    end
  end

  def self.down
    drop_table :clusters
  end
end
