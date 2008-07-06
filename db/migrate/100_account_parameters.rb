class AccountParameters < ActiveRecord::Migration

  def self.up
    add_column :accounts, :account_type_id, :integer
    add_column :accounts, :last_active_at, :datetime, :default => 0
    add_column :accounts, :created_at, :datetime
    add_column :accounts, :updated_at, :datetime
    add_column :accounts, :created_by, :integer
    add_column :accounts, :updated_by, :integer
    add_column :accounts, :clip, :string
    add_column :collections, :last_active_at, :datetime, :default => 0
    add_column :users, :last_active_at, :datetime, :default => 0
    remove_column :users, :last_login
    remove_column :users, :workplace
    remove_column :users, :role
    remove_column :users, :phone
    remove_column :users, :collection_id
    remove_column :users, :posts_count
    remove_column :collections, :status
    remove_column :collections, :allow_registration
    remove_column :collections, :invitation
    remove_column :collections, :welcome
    remove_column :collections, :privacy
    remove_column :collections, :background
    remove_column :collections, :faq
    remove_column :collections, :blog_forum_id
    remove_column :collections, :editorial_forum_id
    remove_column :collections, :survey_forum_ud
  end

  def self.down
    remove_column :collections, :last_active_at
    remove_column :accounts, :account_type_id
    remove_column :accounts, :account_type_id
    remove_column :accounts, :clip
    remove_column :accounts, :created_at
    remove_column :accounts, :updated_at
    remove_column :accounts, :created_by
    remove_column :accounts, :updated_by
  end
end
