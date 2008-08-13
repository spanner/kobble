class ReviseUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :remember_token, :string
    add_column :users, :remember_token_expires_at, :datetime
    add_column :users, :status, :integer, :default => '0'
    rename_column :users, :salted_password, :crypted_password
    remove_column :users, :token_expiry
    remove_column :users, :security_token
    remove_column :users, :role
  end

  def self.down
    remove_column :users, :remember_token
    remove_column :users, :remember_token_expires_at
    remove_column :users, :status
    rename_column :users, :crypted_password, :salted_password
    add_column :users, :token_expiry, :datetime
    add_column :users, :security_token, :string
    add_column :users, :role, :string
  end
end
