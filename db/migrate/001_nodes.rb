class Nodes < ActiveRecord::Migration
  
  def self.up
    create_table :nodes do |table|
      table.column :name, :string
      table.column :synopsis, :text
      table.column :notes, :text
      table.column :body, :text
      table.column :edited, :text
      table.column :person_id, :integer
      table.column :user_id, :integer
      table.column :recording_id, :integer
      table.column :status, :string
      table.column :rating, :integer
      table.column :image, :string
      table.column :clip, :string
      
      # these usually refer to the audio file associated with the related recording
      # but occasionally a snippet will come with its own clip
      
      table.column :playfrom, :decimal  #seconds
      table.column :playto,   :decimal  #seconds
    end    
  end

  def self.down
    drop_table :nodes
  end 
end

