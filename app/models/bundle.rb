class Bundle < ActiveRecord::Base

  is_material
  has_many :contained_bundlings, :dependent => :destroy, :class_name => 'Bundling', :foreign_key => 'superbundle_id'

  validates_presence_of :name, :description, :collection
  
  def self.nice_title
    "set"
  end
  
  def members
    contained_bundlings.map { |b| b.member }
  end
  
  def members=(members)
    transaction {
      contained_bundlings.clear
      add(members)
    }
  end
  
  def add(members)
    members.to_a.each do |member|
      contained_bundlings.create! :member => member
    end
  end

  def catch_this(object)
    if self.contained_bundlings.of(object).empty?
      contained_bundlings.create!(:member => object)
      return Material::CatchResponse.new("#{object.name} added to #{self.name}", 'copy', 'success')
    else
      return Material::CatchResponse.new("#{self.name} already contains #{object.name}", '', 'failure')
    end
  end

  def drop_this(object)
    contained_bundlings.delete(self.contained_bundlings.of(object))
    return Material::CatchResponse.new("#{object.name} removed from #{self.name}", 'delete', 'success')
  end
  
  
end

