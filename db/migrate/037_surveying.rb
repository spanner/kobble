class Surveying < ActiveRecord::Migration
    def self.up
      create_table :surveys do |table|
        table.column :created_by, :integer
        table.column :updated_by, :integer
        table.column :created_at, :datetime
        table.column :updated_at, :datetime
        table.column :title, :string
        table.column :description, :text
        table.column :collection_id, :integer
      end

      create_table :questions do |table|
        table.column :created_by, :integer
        table.column :updated_by, :integer
        table.column :created_at, :datetime
        table.column :updated_at, :datetime
        table.column :prompt, :text
        table.column :guidance, :text
        table.column :observations, :text
        table.column :emotions, :text
        table.column :arising, :text
        table.column :survey_id, :integer
        table.column :collection_id, :integer
      end

      add_column :nodes, :question_id, :integer
    end

    def self.down
      drop_table :surveys
      drop_table :questions
      remove_column :nodes, :question_id
    end
  end
