class CatchError < ActionController::MethodNotAllowed 
end

module ActiveRecord
  module Acts #:nodoc:
    module Catcher #:nodoc:

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
            cd = self.initialize_catchers
            cd[klass.to_s.classify]
          end
      
          # here we examine the dispatch table and deduce the proper method
          # action is deferred so that has_many_polymorphs can create its 
          # relationships before we look for them
      
          # eg Scratchpad.acts_as_catcher :scraps, :merge

          def self.initialize_catchers
            return self.catch_dispatch if self.catch_dispatch && self.catch_dispatch.size
            return {} unless self.catch_list
            self.catch_list.each do |assoc|
              if assoc.class == Hash
                assoc.each_pair { |kl, meth| self.set_catch_dispatch(kl.to_s.classify, meth) }
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
                @message = "#{thrown.name} added to #{self.name}"
              when :belongs_to, :has_one
                self.send("#{association}=", thrown)
                @message = "#{self.name} has #{association} #{thrown.name}"
              end
            elsif self.respond_to?(association)
              @message = self.send(association, thrown)
              @message ||= "#{thrown.name} caught by #{self.name}"
            else
              raise CatchError "no such catch relation: #{self.class}->#{dropped.class}"
            end
          end
      
          def drop(dropped)
            association = self.class.get_catch_dispatch(dropped.class)
            reflection = self.class.reflect_on_association(association)
            if (reflection)
              case reflection.macro
              when :has_many
                self.send(association).send('delete', dropped)
              end
              @message = "#{dropped.name} removed from #{self.name}"
            else
              raise CatchError "no such drop relation: #{self.class}->#{dropped.class}"
            end
            
          end
          
          def self.can_catch
            cd = self.initialize_catchers
            cd.keys
          end

          def can_catch
            cd = self.class.can_catch
            cd.map {|classname| classname.downcase} if cd
          end
      
          def self.acts_as_catcher(*associations)
            # STDERR.puts "#{self}.acts_as_catcher(#{associations})"
            self.catch_list ||= []
            self.catch_list += associations
          end
        }

      end #included
    end #catcher
  end #acts
end #ar
