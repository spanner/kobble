class PurgeUsers < ActiveRecord::Migration

  # soon it will matter that everything is equally field-notable

  def self.up
    add_column :users, :name, :string
    User.reset_column_information
    User.find(:all, :conditions => 'status < 100').each { |u| u.destroy }
    User.find(:all).each do |u| 
      u.name = "#{u.firstname} #{u.lastname}"
      u.save!
    end
    remove_column :users, :firstname
    remove_column :users, :lastname
  end

  def self.down
    add_column :users, :firstname, :string
    add_column :users, :lastname, :string
    remove_column :users, :name
  end
end
