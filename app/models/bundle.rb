class Bundle < ActiveRecord::Base

  acts_as_spoke
  has_many :contained_bundlings, :dependent => :destroy, :class_name => 'Bundling', :foreign_key => 'superbundle_id'
  
  def self.nice_title
    "set"
  end
  
  def members
    contained_bundlings.map { |b| b.member }
  end
    
  def catch_this(object)
    if self.contained_bundlings.of(object).empty?
      contained_bundlings.create!(:member => object)
      return CatchResponse.new("#{object.name} added to #{self.name}", 'copy', 'success')
    else
      return CatchResponse.new("#{self.name} already contains #{object.name}", '', 'failure')
    end
  end

  def drop_this(object)
    contained_bundlings.delete(self.contained_bundlings.of(object))
    return CatchResponse.new("#{object.name} removed from #{self.name}", 'delete', 'success')
  end
  
  
end

