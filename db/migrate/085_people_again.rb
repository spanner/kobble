class PeopleAgain < ActiveRecord::Migration

  # for indexing purposes we would prefer all the searchable models to offer the same basic fields:
  # name, body, synopsis, observations, arising, emotions (the latter three being the optional field notes)

  def self.up
    create_table :people do |table|
      table.column :name, :string
      table.column :image, :string
      table.column :clip, :string
      table.column :description, :text
      table.column :body, :text
      table.column :emotions, :text
      table.column :observations, :text
      table.column :arising, :text
      table.column :collection_id, :integer
      table.column :created_by, :integer
      table.column :updated_by, :integer
      table.column :created_at, :datetime
      table.column :updated_at, :datetime
    end
    
    add_column :users, :person_id, :integer
  end

  def self.down
    drop_table :people
    remove_column :users, :person_id
  end
end
