module Kobble
  module Catcher #:nodoc:
    def self.included(base)
      base.class_eval {
        
        class_inheritable_accessor :catchable, :droppable
        self.catchable = []
        self.droppable = []
       
        extend Kobble::CatcherClassMethods
        include Kobble::CatcherInstanceMethods
      }
    end  
  end
  
  module CatcherClassMethods #:nodoc:
      
    def catches_and_drops(klass, options={})
      STDERR.puts ">>> #{self}.catches_and_drops( #{klass}, #{options.inspect} )"
      self.catches(klass, options)
      self.drops(klass, options)
    end
    
    #klass should be a singular symbol: 
    #   Node.can_catch(:tag)
    #   Bundle.can_catch(:node, :through => :bundlings)
    #   User.can_catch(:node, :through => :markers, :as => :selection)

    def catches(klass, options={})
      if options[:through]
        # we assume that if we're going :through it is to reach a polymorphic associate
        options[:as] ||= options[:through].to_s.as_class.find_polymorphic_target
        define_method :"catch_#{klass}" do |object|
          if self.send(options[:through]).of(object).empty?
            raise Kobble::CatchAlreadyPresent if send(options[:through]).of(object).any?
            options[:as] ||= options[:through].as_class.find_polymorphic_target
            send(options[:through]).create!(options[:as] => object) 
            Kobble::Response.new :message => "#{object.name} caught"
          end
        end
      else
        define_method :"catch_#{klass}" do |object|
          raise Kobble::CatchAlreadyPresent if send(klass.to_s.pluralize.downcase.intern).include?(object)
          send(klass.to_s.pluralize.downcase.intern) << object
          Kobble::Response.new :message => "#{object.name} caught"
        end
      end
      self.catchable.push(klass)
    end

    def drops(klass, options={})
      if options[:through]
        define_method :"drop_#{klass}" do |object|
          raise Kobble::DropNotPresent unless send(options[:through]).of(object).any?
          send(options[:through]).of(object).each {|this| this.delete}
          Kobble::Response.new :message => "#{object.name} dropped"
        end
      else
        define_method :"drop_#{klass}" do |object|
          raise Kobble::DropNotPresent unless send(klass.to_s.pluralize.downcase.intern).include?(object)
          send(klass.to_s.pluralize.downcase.intern).delete(object)
          Kobble::Response.new :message => "#{object.name} dropped"
        end
      end
      self.droppable.push(klass)
    end        

    def catchable_models
      self.catchable
    end

    def can_catch?(klass)
      not self.catchable.contains?(klass.to_s.downcase.intern)
    end

    def droppable_models
      self.droppable
    end

    def can_drop?(klass)
      not self.droppable.contains?(klass.to_s.downcase.intern)
    end
    
    def find_polymorphic_target
      association = self.reflect_on_all_associations.find{ |ass| ass.options[:polymorphic] }
      logger.warn ">>> first polymorphic association in #{self} is #{association.name}"
      return association.name
    end
  end

  module CatcherInstanceMethods #:nodoc:
    
    def catch_this(object)
      self.send "catch_#{object.class.to_s.downcase}".intern, object
    rescue Kobble::CatchAlreadyPresent => e
      STDERR.puts "That's already there"
    rescue => e
      STDERR.puts "That didn't work at all: #{e}"
    end

    def drop_this(object)
      self.send "drop_#{object.class.to_s.downcase}".intern, object
    rescue Kobble::DropNotPresent => e
      STDERR.puts "Can't drop that: it's not there"
    rescue Kobble::Error => e
      STDERR.puts "That didn't work at all: #{e}"
    end
    
    def catchlist                                  # used to transfer list of possible catch classes to javascript
      self.catchable.join(',')
    end

    def catcher?
      return true unless self.catchable.empty?
      false
    end

    def dropper?
      return true unless self.droppable.empty?
      false
    end
    
    def catchable_models
      self.class.catchable_models
    end

    def droppable_models
      self.class.droppable_models
    end

    def can_catch?(thing)
      self.class.can_catch?(thing.class)
    end

    def can_drop?(thing)
      self.class.can_drop?(thing.class)
    end

  end
end

