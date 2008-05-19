class AccountTypes < ActiveRecord::Migration
  def self.up
    personal = AccountType.new({
      :name => 'personal',
      :price_monthly => 0,
      :price_yearly => 0,
      :can_audio => true,
      :can_video => true,
      :users_limit => 1,
      :space_limit => 100,
      :description => "A full-featured free account that you can use to gather text, audio and video for your own use."
    }).save
    small = AccountType.new({
      :name => 'team basic',
      :price_monthly => 9,
      :price_yearly => 100,
      :can_audio => false,
      :can_video => false,
      :users_limit => 10,
      :space_limit => 20,
      :description => "A cheap and useful account that you can use to gather and share text, documents and images among a small team."
    }).save
    big = AccountType.new({
      :name => 'team proper',
      :price_monthly => 29,
      :price_yearly => 300,
      :can_audio => true,
      :can_video => true,
      :users_limit => 50,
      :space_limit => 1024,
      :description => "A fully-loaded account suitable for research, knowledge-capture and documentation within a large team."
    })
    big.save
    
    Account.find(:all).each do |acc| 
      acc.account_type = big 
      acc.save
    end
    
  end

  def self.down
  end
end
