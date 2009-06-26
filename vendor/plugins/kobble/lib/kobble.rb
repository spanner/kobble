module Kobble  #:nodoc:
  
  
  # the object_model lists holds all models for which is_material has been declared
  # the others hold lists of models that participate in specific kobble functions

  # all of these methods keep the model name as a (singular) symbol
  # holding classes in plugin causes staleness in dev mode
  
  %w{object indexed discussed described organised bookmarked annotated logged}.each do |listed|

    mattr_accessor "#{listed}_models".intern
    module_eval <<-EOE

      def Kobble.#{listed}_model(klass)
        @@#{listed}_models ||= []
        @@#{listed}_models.push(klass.to_s.underscore.intern) unless Kobble.#{listed}_model?(klass)
      end

      def Kobble.#{listed}_model?(klass)
        @@#{listed}_models.include?(klass.to_s.underscore.intern)
      end

    EOE
  end
  
end #kobble
