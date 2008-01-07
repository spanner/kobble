module ActiveRecord; module Acts; end; end 

module ActiveRecord::Acts::Catchable
  
  def self.included(base)
    base.class_eval {
                        
      class << self; 
        attr_accessor :catch_list, :catch_dispatch
      end

      def self.set_catch_dispatch(klass, kall)
        # STDERR.puts("    #{self.to_s}.set_catch_dispatch(#{klass}, #{kall})")
        self.catch_dispatch ||= {}
        self.catch_dispatch[klass.to_s] ||= kall
      end
      
      def self.get_catch_dispatch(klass)
        self.initialize_catchers
        self.catch_dispatch[klass.to_s]
      end
      
      # here we examine the dispatch table and deduce the proper method
      # deferred so that has_many_polymorphs can create its relationships
      
      # nbeg Scratchpad.acts_as_catcher :scraps, :merge

      def self.initialize_catchers
        return self.catch_dispatch if self.catch_dispatch && self.catch_dispatch.size
        self.catch_list.each do |assoc|
          if assoc.class == Hash
            assoc.each_pair { |kl, meth| self.set_catch_dispatch(kl, meth) }
          else
            reflection = self.reflect_on_association(assoc)
            if reflection
              if reflection.macro == :has_many_polymorphs
                reflection.options[:from].each { |k| self.set_catch_dispatch( k.to_s.classify, k.to_s.underscore.pluralize.intern) } 
              else
                self.set_catch_dispatch(reflection.class_name.to_s, reflection.name)
              end
            end
          end
        end
        return self.catch_dispatch
      end

      public 
      
      def catch(thrown)
        association = self.class.get_catch_dispatch(thrown.class)
        # STDERR.puts "#{self}.catch(#{thrown}) -> #{association}"
        reflection = self.class.reflect_on_association(association)
        if (reflection)
          case reflection.macro
          when :has_many
            self.send(association) << thrown
          when :belongs_to, :has_one
            self.send("#{association}=", thrown)
          end
        elsif self.respond_to?(association)
          self.send(association, thrown)
        end
      end

      def throw(catcher)
        catcher.catch(self)
      end
      
      def drop(dropped)
        association = self.class.get_catch_dispatch(dropped.class)
        reflection = self.class.reflect_on_association(association)
        if (reflection)
          case reflection.macro
          when :has_many
            collection = self.send(association).send('delete', dropped)
          end
        end
      end
      
      def self.acts_as_catcher(*associations)
        # STDERR.puts "#{self}.acts_as_catcher(#{associations})"
        self.catch_list ||= []
        self.catch_list += associations
      end
      
    }
  end

end
