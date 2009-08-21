class Bundle < ActiveRecord::Base
  
  def self.create_accessors_for(klass)
    Bundling.send(:named_scope, "of_#{klass.to_s.downcase.pluralize}".intern, :conditions => { :member_type => klass.to_s })
    define_method("#{klass.to_s.downcase}_bundlings") { self.contained_bundlings.send("of_#{klass.to_s.downcase.pluralize}".intern) }
    define_method("#{klass.to_s.downcase.pluralize}") { self.send("#{klass.to_s.to_s.downcase}_bundlings".intern).map{|l| l.member}.uniq }
  end

  is_material
  has_many :contained_bundlings, :dependent => :destroy, :class_name => 'Bundling', :foreign_key => 'superbundle_id'
  validates_presence_of :name, :description, :collection
  
  def self.nice_title
    "set"
  end
  
  def members
    contained_bundlings.map { |b| b.member }.uniq
  end
  
  def members=(members)
    transaction {
      contained_bundlings.clear
      add(members)
    }
  end
  
  def add(members)
    members.to_a.uniq.each do |member|
      contained_bundlings.create! :member => member
    end
  end
  
  def summarise_members
    types = []
    Kobble.organised_models.each do |klass|               # :node
      members = send(klass.to_s.pluralize.intern)         # .nodes
      count = members.length
      if count > 0
        label = klass.to_s.as_class.nice_title            # fragment
        label = label.pluralize unless count == 1         # fragments
        types << "#{count} #{label}"                      # 17 fragments
      end
    end
    types.to_sentence(:skip_last_comma => true) if types.any?
  end
  
  
end

