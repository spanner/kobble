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
    
    def can_catch(models)
      self.catchable.push *models
    end

    def can_catch?(model)
      self.catchable.contains? model
    end
    
    def catchable_models
      self.catchable
    end
  end

  module CatcherInstanceMethods #:nodoc:
    
    def catchlist
      self.class.catchable_models.join(',')
    end

    def catcher?
      not self.catchable_models.empty?
    end

    def catchable_models
      self.class.catchable_models
    end

    def can_catch?(thing)
      self.class.can_catch?(thing.class)
    end

  end
end

