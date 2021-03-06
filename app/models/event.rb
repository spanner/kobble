class Event < ActiveRecord::Base

  belongs_to :account
  belongs_to :collection
  belongs_to :user
  belongs_to :affected, :polymorphic => true

  named_scope :latest, { :limit => 20, :order => 'at DESC' }
  named_scope :latest_few, { :limit => 5, :order => 'at DESC' }
  named_scope :most_recent, { :limit => 1, :order => 'at DESC' }
  named_scope :since, lambda {|start| { :conditions => ['at > ?', start] } }
  named_scope :of_type, lambda {|type| { :conditions => {:event_type => type}, :order => 'at DESC' } }
  
  # override so that we can see deleted objects too
  
  def affected
    self.affected_type.as_class.find_with_deleted(self.affected_id) rescue nil
  end
  
end
