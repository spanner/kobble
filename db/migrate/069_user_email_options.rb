class UserEmailOptions < ActiveRecord::Migration
  def self.up
    add_column :users, :receive_questions_email, :integer, :default => 1
    add_column :users, :receive_news_email, :integer, :default => 1
  end

  def self.down
    remove_column :users, :receive_questions_email
    add_column :users, :receive_news_email
  end
end
