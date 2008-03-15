class Bundle < ActiveRecord::Base

  has_many_polymorphs :members, :as => 'superbundle', :from => self.organised_classes, :through => :bundlings, :dependent => :destroy
  acts_as_catcher :members
  acts_as_spoke
  
  def self.index_fields
    STDERR.puts "%%% Bundle.index_fields (self is #{self})"
    ['name', 'description', 'body', 'created_by', 'created_at', 'collection_id']
  end

  def self.index_concatenation
    STDERR.puts "%%% Bundle.index_concatenation (self is #{self})"
    [{:fields => ['observations', 'arising', 'emotions'], :as => 'field_notes'}]
  end
  
  def self.nice_title
    "set"
  end
end

