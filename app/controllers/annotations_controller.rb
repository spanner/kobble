class AnnotationsController < CollectionScopedController
  
  before_filter :find_annotated, :only => [:new, :create]
  before_filter :find_note_types, :only => [:new, :edit]
  
  protected
  
    def find_annotated
      ref = Kobble.annotated_models.find{ |k| !params[("#{k.to_s}_id").intern].nil? }
      @thing.annotated = ref ? ref.to_s.as_class.find(params[(ref.to_s.underscore + "_id").intern]) : nil
    end
    
    def find_note_types
      @annotation_types = AnnotationType.find(:all, :order => 'name').collect{|at| [at.name, at.id] }
    end

end
