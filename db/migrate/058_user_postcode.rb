class UserPostcode < ActiveRecord::Migration
  def self.up
    add_column :users, :postcode, :string, :limit => 8
  end

  def self.down
    remove_column :users, :postcode
  end
end
