class Event < ActiveRecord::Base

  belongs_to :account
  belongs_to :collection
  belongs_to :user
  belongs_to :affected, :polymorphic => true

  named_scope :since, lambda {|start| { :conditions => ['at > ?', start] } }
  named_scope :latest, lambda {|count| { :limit => (count || 5), :order => 'at DESC' } }
  named_scope :of_type, lambda {|type| { :conditions => {:event_type => type}, :order => 'at DESC' } }
  
  # override to get deleted objects too
  
  def affected
    self.affected_type._as_class.find_with_deleted(self.affected_id)
  end
  
end
