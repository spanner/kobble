class InitializeAccounts < ActiveRecord::Migration

  # for each person who owns collections, we need to create an account object and give it those collections
  # then people who have some status and who belong to one of those collection will be moved so that they belong to the account

  def self.up
    User.find(:all).each do |u|
      unless (u.created_collections.empty?)
        puts "creating account for #{u.name}"
        a = u.account || Account.new(
          :name => u.name + "'s account",
          :status => 'active',
          :user => u
        )
        a.save!
        u.created_collections.each do |c| 
          c.account = a
          c.users.each do |cu|
            cu.account = a if cu.editor?
            cu.save
          end
          c.save
        end
        u.account = a
        u.save
      end
    end
  end

  def self.down

  end
end
