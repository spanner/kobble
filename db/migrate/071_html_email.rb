class HtmlEmail < ActiveRecord::Migration
  def self.up
    add_column :users, :receive_html_email, :integer
  end

  def self.down
    remove_column :users, :receive_html_email
  end
end
