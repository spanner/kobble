module Spoke
  module Associations
    
    mattr_accessor :indexed_models, :discussed_models, :described_models, :organised_models, :annotated_models, :logged_models
    
    # all of these methods keep the model name as a (singular) symbol
    # holding classes in plugin causes staleness in dev mode
         
    def self.indexed_model(klass)
      @@indexed_models ||= []
      @@indexed_models.push(klass.to_s.underscore.intern) unless @@indexed_models.include?(klass.to_s.underscore.intern)
    end

    def self.discussed_model(klass)
      @@discussed_models ||= []
      @@discussed_models.push(klass.to_s.underscore.intern) unless @@discussed_models.include?(klass.to_s.underscore.intern)
    end
    
    def self.described_model(klass)
      @@described_models ||= []
      @@described_models.push(klass.to_s.underscore.intern) unless @@described_models.include?(klass.to_s.underscore.intern)
    end

    def self.organised_model(klass)
      @@organised_models ||= []
      @@organised_models.push(klass.to_s.underscore.intern) unless @@organised_models.include?(klass.to_s.underscore.intern)
    end

    def self.annotated_model(klass)
      @@annotated_models ||= []
      @@annotated_models.push(klass.to_s.underscore.intern) unless @@annotated_models.include?(klass.to_s.underscore.intern)
    end

    def self.logged_model(klass)
      @@logged_models ||= []
      @@logged_models.push(klass.to_s.underscore.intern) unless @@logged_models.include?(klass.to_s.underscore.intern)
    end
    
  end
end
