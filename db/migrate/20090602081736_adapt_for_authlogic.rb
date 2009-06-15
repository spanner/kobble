class AdaptForAuthlogic < ActiveRecord::Migration
  def self.up
    add_column :users, :persistence_token, :string, :null => false
    add_column :users, :single_access_token, :string, :null => false
    add_column :users, :perishable_token, :string, :null => false
    add_column :users, :login_count, :integer, :null => false, :default => 0
    add_column :users, :failed_login_count, :integer, :null => false, :default => 0
    add_column :users, :current_login_ip, :string
    add_column :users, :last_login_ip, :string

    change_column :users, :salt, :string
    change_column :users, :crypted_password, :string
    
    rename_column :users, :last_active_at, :last_request_at
    rename_column :users, :logged_in_at, :last_login_at
    rename_column :users, :salt, :password_salt
  end
  
  def self.down

  end
end
