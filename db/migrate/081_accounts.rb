class Accounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |table|
      table.column :user_id, :integer
      table.column :name, :string
      table.column :image, :string
      table.column :status, :string
    end
    add_column :collections, :account_id , :integer
    add_column :users, :account_id , :integer
    remove_column :collections, :user_id
  end

  def self.down
    drop_table :accounts
    remove_column :collections, :account_id
    remove_column :users, :account_id
    add_column :collections, :user_id, :integer
  end
end
