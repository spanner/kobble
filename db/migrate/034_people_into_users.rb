class Node < ActiveRecord::Base
  belongs_to :user
  
end
class Bundle < ActiveRecord::Base
  belongs_to :user
  
end
class User < ActiveRecord::Base
  
end
class Person < ActiveRecord::Base

  belongs_to :collection
  
  def to_user 
    nameparts = name.split(' ')
    firstname = nameparts.shift
    lastname = nameparts.join(' ')
    u = User.find (:first, 
      :conditions => ['firstname = ? AND lastname = ?', firstname, lastname]
    )
    if (u.nil?) then
      u = User.create (
        :firstname => firstname,
        :lastname => lastname,
        :image => image,
        :description => description,
        :collection => collection
      )
      u.save!
      puts "new User #{u.id}: #{u.lastname}, #{u.firstname}"
    else
      puts "existing User #{u.id}"
    end
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
       u.type = 'User'
       u.save!
     end
     
    Source.find(:all).each do |s|
      puts("working on #{s.name}")
      s.creator = s.user
      s.user = s.person.to_user
      s.save!
    end
    
    Node.find(:all).each do |n|
      n.created_by = n.user
      n.user = n.source ? n.source.user : nil
      n.save
    end

    Bundle.find(:all).each do |b|
      b.created_by = b.user
      b.user = nil
      b.save
    end

  end

  def self.down
    Source.find(:all).each do |s|
      s.user = s.creator
    end
  end
end
