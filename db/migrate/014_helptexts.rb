class Helptexts < ActiveRecord::Migration
  def self.up
      create_table :helptexts do |table|
        table.column :id, :integer
        table.column :name, :string
        table.column :body, :text
        table.column :user_id, :integer
        
      end
    end

    def self.down
      drop_table :helptexts
  end
end
