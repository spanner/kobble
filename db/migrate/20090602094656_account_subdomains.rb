class AccountSubdomains < ActiveRecord::Migration
  def self.up
    add_column :accounts, :subdomain, :string
    add_index :accounts, :subdomain, :unique => true
    Account.reset_column_information
    Account.find(:all).each do |account|
      account.subdomain = account.name
      account.save
    end
  end

  def self.down
    remove_index :accounts, :subdomain
    remove_column :accounts, :subdomain
  end
end
