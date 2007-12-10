module ActiveRecord; module Acts; end; end 

module ActiveRecord::Acts::Catchable
  
  def self.included(base)
    base.class_eval {
                        
      class << self; 
        attr_accessor :catch_dispatch; 
      end

      def self.set_catch_dispatch(klass, kall)
        cd = klass.catch_dispatch || {}
        cd[self.to_s] ||= kall
        klass.catch_dispatch = cd
      end
      
      def self.get_catch_dispatch(klass)
        cd = klass.catch_dispatch || {}
        cd[self.to_s]
      end
      
      public 
      
      def do_catch(catcher)
        catcher.send(catcher.class.get_catch_dispatch(self.class), self)
      end

      def self.acts_as_catchable(*associations)

        associations.each do |assoc|
          STDERR.puts(">>> make catchable: #{self}.#{assoc.to_s}")
          reflection = self.reflect_on_association(assoc)
          if reflection
            STDERR.puts("<<< #{self} catches #{reflection.name.to_s} (#{reflection.macro})")
            case reflection.macro
            when :has_many_polymorphs
              reflection.options[:from].each {|k| k.to_s.class_name.set_catch_dispatch( reflection.name.to_s + '.push' ) }
              
            # when :has_many
            #   self.set_drop_dispatch(reflection.class_name, reflection.name.to_s + '.push')
            # when :belongs_to, :has_one
            #   self.set_drop_dispatch(reflection.class_name, reflection.name.to_s + '=')
            else

            end
          end
        end
      end
      
    }
  end

end
