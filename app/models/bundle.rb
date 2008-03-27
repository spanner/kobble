class Bundle < ActiveRecord::Base

  has_many :bundlings, :dependent => :destroy, :as => 'superbundle'
  has_many_polymorphs :members, :as => 'superbundle', :from => Spoke::Config.content_models, :through => :bundlings, :dependent => :destroy
  acts_as_spoke
  acts_as_catcher :members
  
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

