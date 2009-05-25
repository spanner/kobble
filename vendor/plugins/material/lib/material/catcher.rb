module Material
  module Catcher #:nodoc:
    def self.included(base)
      base.class_eval {
                      
        class << self; 
          attr_accessor :catchable, :droppable
        end
          
        # class names stored as singular symbol to uncouple from particular Class object
        # storing classes causes stale object problems in dev mode because class 
        # reloaded but plugin not. Any string, symbol or class should work if passed in
          
        def self.can_catch(klass)
          self.catchable ||= []
          self.catchable.push(klass.to_s.downcase.intern) unless self.catchable.include?(klass.to_s.downcase.intern)
        end

        def self.can_drop(klass)
          self.droppable ||= []
          self.droppable.push(klass.to_s.downcase.intern) unless self.droppable.include?(klass.to_s.downcase.intern)
        end

        def self.catchable_classes
          self.catchable
        end

        def self.droppable_classes
          self.droppable
        end
        
        def self.can_catch?(klass)
          self.catchable_classes.include?(klass.to_s.downcase.intern)
        end

        def self.can_drop?(klass)
          self.droppable_classes.include?(klass.to_s.downcase.intern)
        end
        
        def catchable_classes
          self.class.catchable_classes
        end

        def droppable_classes
          self.class.droppable_classes
        end
        
        def catchlist
          self.catchable_classes.join(',')
        end

        def catcher?
          return true unless self.catchable_classes.nil? || self.catchable_classes.empty?
          false
        end

        def dropper?
          return true unless self.droppable_classes.nil? || self.droppable_classes.empty?
          false
        end

        def can_catch?(klass)
          self.class.can_catch?(klass)
        end

        def can_drop?(klass)
          self.class.can_drop?(klass)
        end
        
        unless self.respond_to?('catch_this')
          def catch_this(thrown)
            # sensible default?
            raise Material::CatchError, "you need to define a catch_this method in class #{self.class.to_s}"
          end
        end
        
        unless self.respond_to?('drop_this')
          def drop_this(dropped)
            # sensible default?
            raise Material::CatchError, "you need to define a drop_this method in class #{self.class.to_s}"
          end
        end
    
      }

    end #included
  end #catcher
end #ar

