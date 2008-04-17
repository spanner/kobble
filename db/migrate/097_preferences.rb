class Preferences < ActiveRecord::Migration

  # preference objects and user_preference objects
  # (at the moment, only boolean preferences)

  def self.up
    create_table :preferences do |table|
      table.column :name, :string
      table.column :description, :text
      table.column :created_by, :integer
      table.column :updated_by, :integer
      table.column :created_at, :datetime
      table.column :updated_at, :datetime
    end
    create_table :user_preferences do |table|
      table.column :user_id, :integer
      table.column :preference_id, :integer
      table.column :active, :boolean, :default => false
    end
  end

  def self.down
    drop_table :preferences
    drop_table :user_preferences
  end
end
