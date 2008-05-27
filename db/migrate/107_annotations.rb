class Annotations < ActiveRecord::Migration
  def self.up
    create_table :annotations do |table|
      table.column :annotated_id, :integer
      table.column :annotated_type, :string
      table.column :annotation_type_id, :integer
      table.column :body, :text
      table.column :created_by, :integer
      table.column :updated_by, :integer
      table.column :created_at, :datetime
      table.column :updated_at, :datetime
    end
    create_table :annotation_types do |table|
      table.column :name, :string
      table.column :description, :text
      table.column :created_by, :integer
      table.column :updated_by, :integer
      table.column :created_at, :datetime
      table.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :annotations
    drop_table :annotation_types
  end
end
