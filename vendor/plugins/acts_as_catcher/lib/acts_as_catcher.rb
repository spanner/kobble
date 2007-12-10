module ActiveRecord; module Acts; end; end 

module ActiveRecord::Acts::Catcher
  
  def self.included(base)
    base.class_eval {
      
      class << self; attr_accessor :drop_dispatch; end
      
      def self.acts_as_catcher(*associations)

        self.class_eval {
          def self.set_drop_dispatch(klass, kall, options={})
            dd = self.drop_dispatch || {}
            return unless !dd[klass.to_s] || dd[klass.to_s].nil? || options[:insist]
            dd[klass.to_s] = kall
            self.drop_dispatch = dd
          end
          
          def self.get_drop_dispatch(klass)
            dd = self.drop_dispatch || {}
            dd[klass]
          end
          
          public 
          
          def self.receive_drop(dropped)
            self.send(self.get_drop_dispatch(dropped.class), dropped)
          end
        }
        
        associations.each do |assoc|
          STDERR.puts("catching association: #{self}.#{assoc.to_s}")
          reflection = self.reflect_on_association(assoc)
          if reflection
            STDERR.puts("#{self} catching #{reflection.name.to_s} (#{reflection.macro})")
            case reflection.macro
            when :has_many_polymorphs
              reflection.options[:from].each {|k| self.set_drop_dispatch(k.to_s.camelize, reflection.name.to_s + '.push') }
            when :has_many
              self.set_drop_dispatch(reflection.class_name, reflection.name.to_s + '.push')
            when :belongs_to, :has_one
              self.set_drop_dispatch(reflection.class_name, reflection.name.to_s + '=')
            else

            end
          end
        end
      end
      
    }
  end

end
