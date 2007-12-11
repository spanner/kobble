module ActiveRecord; module Acts; end; end 

module ActiveRecord::Acts::Catchable
  
  def self.included(base)
    base.class_eval {
                        
      class << self; 
        attr_accessor :catch_dispatch; 
      end

      def self.set_catch_dispatch(klass, kall)
        # STDERR.puts("    #{self.to_s}.set_catch_dispatch(#{klass}, #{kall})")
        cd = self.catch_dispatch || {}
        cd[klass.to_s] ||= kall
        self.catch_dispatch = cd
      end
      
      def self.get_catch_dispatch(klass)
        cd = self.catch_dispatch || {}
        cd[klass.to_s]
      end
      
      public 
      
      def catch(thrown)
        self.send(self.class.get_catch_dispatch(thrown.class), thrown)
      end

      def throw(catcher)
        catcher.catch(self)
      end

      def self.acts_as_catcher(*associations)
        associations.each do |assoc|
          # STDERR.puts(">>> make catcher: #{self}.#{assoc.to_s}")
          reflection = self.reflect_on_association(assoc)
          if reflection
            # STDERR.puts("    #{self} catches #{reflection.name.to_s} (#{reflection.macro})")
            case reflection.macro
            when :has_many_polymorphs
              reflection.options[:from].each { |k| self.set_catch_dispatch( k.to_s, reflection.name.to_s + '.push' ) } 
            when :has_many
              self.set_catch_dispatch(reflection.class_name, reflection.name.to_s + '.push')
            when :belongs_to, :has_one
              self.set_catch_dispatch(reflection.class_name, reflection.name.to_s + '=')
            end
          end
        end
      end

      def self.acts_as_catchable(*associations)
        associations.each do |assoc|
          # STDERR.puts("<<< make catchable: #{self}.#{assoc.to_s}")
          reflection = self.reflect_on_association(assoc)
          if reflection
            # STDERR.puts("    #{self} catchable by #{reflection.name.to_s} (#{reflection.macro})")
            case reflection.macro
            when :has_many_polymorphs
              reflection.options[:from].each { |k| k._as_class.set_catch_dispatch( self.to_s, reflection.name.to_s + '.push' ) } 
            when :has_many
              reflection.class_name.classify.set_drop_dispatch(self.to_s, reflection.name.to_s + '.push')
            when :belongs_to, :has_one
              reflection.class_name.classify.set_drop_dispatch(self.to_s, reflection.name.to_s + '=')
            end
          end
        end
      end
      
    }
  end

end
