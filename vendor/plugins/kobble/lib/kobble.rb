module Kobble  #:nodoc:
  
  mattr_accessor :object_models, :indexed_models, :discussed_models, :described_models, :organised_models, :bookmarked_models, :annotated_models, :logged_models
  
  # all of these methods keep the model name as a (singular) symbol
  # holding classes in plugin causes staleness in dev mode

  # this first one holds all models for which is_material has been declared

  def Kobble.object_model(klass)
    @@object_models ||= []
    @@object_models.push(klass.to_s.underscore.intern) unless @@object_models.include?(klass.to_s.underscore.intern)
  end

  # these others hold lists of models that participate in specific kobble functions

  def Kobble.indexed_model(klass)
    @@indexed_models ||= []
    @@indexed_models.push(klass.to_s.underscore.intern) unless @@indexed_models.include?(klass.to_s.underscore.intern)
  end

  def Kobble.discussed_model(klass)
    @@discussed_models ||= []
    @@discussed_models.push(klass.to_s.underscore.intern) unless @@discussed_models.include?(klass.to_s.underscore.intern)
  end
  
  def Kobble.described_model(klass)
    @@described_models ||= []
    @@described_models.push(klass.to_s.underscore.intern) unless @@described_models.include?(klass.to_s.underscore.intern)
  end

  def Kobble.organised_model(klass)
    @@organised_models ||= []
    @@organised_models.push(klass.to_s.underscore.intern) unless @@organised_models.include?(klass.to_s.underscore.intern)
  end

  def Kobble.bookmarked_model(klass)
    @@bookmarked_models ||= []
    @@bookmarked_models.push(klass.to_s.underscore.intern) unless @@bookmarked_models.include?(klass.to_s.underscore.intern)
  end

  def Kobble.annotated_model(klass)
    @@annotated_models ||= []
    @@annotated_models.push(klass.to_s.underscore.intern) unless @@annotated_models.include?(klass.to_s.underscore.intern)
  end

  def Kobble.logged_model(klass)
    @@logged_models ||= []
    @@logged_models.push(klass.to_s.underscore.intern) unless @@logged_models.include?(klass.to_s.underscore.intern)
  end
  
end #kobble
