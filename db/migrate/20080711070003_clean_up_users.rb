class CleanUpUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :postcode
    remove_column :users, :delete_after
    remove_column :users, :deleted
    remove_column :users, :verified
    remove_column :users, :honorific
    remove_column :users, :receive_news_email
    remove_column :users, :receive_html_email
    remove_column :users, :subscribe_everything
  end

  def self.down
    add_column :users, :postcode, :string
    add_column :users, :delete_after, :datetime
    add_column :users, :deleted, :integer
    add_column :users, :verified, :integer
    add_column :users, :honorific, :string
    add_column :users, :receive_news_email, :integer
    add_column :users, :receive_html_email, :integer
    add_column :users, :subscribe_everything, :integer
  end
end
