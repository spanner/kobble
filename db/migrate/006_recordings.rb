class Recordings < ActiveRecord::Migration
  def self.up
    create_table :recordings do |table|
      table.column :id, :integer
      table.column :name, :string
      table.column :notes, :text
      table.column :synopsis, :text
      table.column :person_id, :integer
      table.column :uploader, :integer
      table.column :body, :longtext
      table.column :clip, :string
      table.column :duration, :decimal  #seconds
      table.column :rating, :integer
   end    
  end

  def self.down
    drop_table :recordings
  end 
end
