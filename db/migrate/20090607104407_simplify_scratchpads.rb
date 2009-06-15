class SimplifyScratchpads < ActiveRecord::Migration
  def self.up
    create_table :bookmarkings do |table|
      table.column :bookmark_type, :string, :limit => 20
      table.column :bookmark_id, :integer
      table.column :collection_id, :integer
      table.column :position, :integer
      table.column :created_by_id, :integer
      table.column :created_at, :datetime
      table.column :updated_by_id, :integer
      table.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :bookmarkings
  end
end
