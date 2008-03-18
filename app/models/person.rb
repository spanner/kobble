class Person < ActiveRecord::Base

  acts_as_spoke
  has_many :sources, :class_name => 'Source', :foreign_key => 'speaker_id'
  has_many :nodes, :class_name => 'Node', :foreign_key => 'speaker_id'
  has_one :user
  
  def self.nice_title
    "person"
  end

  def currently_visible
    
  end

end
