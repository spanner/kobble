class Users < ActiveRecord::Migration
  def self.up
    create_table :users do |table|
      table.column :id, :integer
      table.column :login, :string, :limit => 80, :null => false
      table.column :salted_password, :string, :limit => 40, :null => false
      table.column :email, :string, :limit => 60, :null => false
      table.column :diminutive, :string, :limit => 40
      table.column :firstname, :string, :limit => 40
      table.column :lastname, :string, :limit => 40
      table.column :salt, :string, :limit => 40, :null => false
      table.column :verified, :int, :default => 0
      table.column :role, :string, :limit => 40
      table.column :security_token, :string, :limit => 40
      table.column :token_expiry, :datetime
      table.column :created_at, :datetime
      table.column :updated_at, :datetime
      table.column :logged_in_at, :datetime
      table.column :deleted, :int, :default => 0
      table.column :delete_after, :datetime
    end
  end

  def self.down
    drop_table :users
  end
end
