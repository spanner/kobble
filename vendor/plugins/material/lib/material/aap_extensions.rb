module Material
  module AapExtensions

    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end

    # cascading recover
    # for inclusion into ActiveRecord::Base
    # but better thought of as an extension to acts_as_paranoid

    def retrievable_associates
      associates = []
      self.class.retrievable_associations.each do |association| 
        associates += association.class_name._as_class.find_with_deleted(:all, :conditions => conditions_for(association))
      end
      associates
    end

    def retrievable_associates_summary
      totals = []
      self.class.retrievable_associations.each do |association| 
        total = association.class_name._as_class.count_with_deleted(:conditions => conditions_for(association))
        designation = association.class_name._as_class.nice_title
        designation = designation.pluralize unless total == 1
        totals.push("#{total} #{designation}") if total > 0
      end
      totals.empty? ? 'none' : totals.to_sentence
    end
  
    # polymorphic associations need more conditions
  
    def conditions_for(association)
      if association.options[:as]
        { association.primary_key_name => self.id, association.primary_key_name.gsub('_id', '_type') => self.class.to_s }
      else
        { association.primary_key_name => self.id }
      end
    end
    
    module ClassMethods
      def retrievable_associations
        reflect_on_all_associations.select{ |a| a.options[:dependent] == :destroy && a.class_name._as_class.paranoid? }
      end
    end

  end
end
