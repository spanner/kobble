class OptionalNotification < ActiveRecord::Migration
  def self.up
    # add_column :questions, :send_email, :integer, :default => 0
  end

  def self.down
    # remove_column :questions, :send_email
  end
end
