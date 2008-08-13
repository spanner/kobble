class BlogTables < ActiveRecord::Migration
  def self.up
    create_table :blogentries do |table|
      table.column :created_by, :integer
      table.column :updated_by, :integer
      table.column :created_at, :datetime
      table.column :updated_at, :datetime
      table.column :name, :string
      table.column :introduction, :text
      table.column :body, :text
      table.column :collection_id, :integer
      table.column :node_id, :string
      table.column :image, :string
      table.column :clip, :string
      table.column :caption, :text
    end
  end

  def self.down
    drop_table :blogentries
  end
end
