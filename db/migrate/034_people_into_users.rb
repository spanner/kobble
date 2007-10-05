class User < ActiveRecord::Base
  
end
class Person < ActiveRecord::Base

  def to_user 
    nameparts = name.split(' ')
    firstname = nameparts.shift
    lastname = nameparts.join(' ')
    u = User.create (
      :firstname => firstname,
      :lastname => lastname,
      :image => image,
      :description => description,
      :collection => collection
    )
    puts "new User: #{u.lastname}, #{u.firstname}"
    u.save!
    u
  end
end

class Source < ActiveRecord::Base
  belongs_to :person
  belongs_to :user
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by" 
end

class PeopleIntoUsers < ActiveRecord::Migration
  
  def self.up
    User.find(:all).each do |u|
       u.type = 'LoginUser'
       u.save!
     end
     
    Source.find(:all).each do |s|
      puts("working on #{s.name}")
      s.creator = s.user
      s.user = s.person.to_user
      s.save!
    end
  end

  def self.down
    Source.find(:all).each do |s|
      s.user = s.creator
    end
  end
end
