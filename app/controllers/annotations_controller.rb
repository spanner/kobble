class AnnotationsController < ApplicationController

  # only accessible as nested resource of annotated object
  # and normally only as a jsonised ajax call
  # notes are only displayed on the object page but can be padded and dropped onto other objects, 
  # whereupon they are duplicated, not shared
  
  before_filter :find_annotated
  before_filter :find_note_types, :only => [:new, :edit]
  
  def new
    @annotation = Annotation.new
    @annotation.annotated = @annotated
    respond_to do |format|
      format.html { }
      format.js { render :layout => 'inline' }
      format.json { render :json => @annotation.to_json }
    end
  end
  
  def create
    @annotation = Annotation.new(params[:annotation])
    @annotation.annotated = @annotated
    if @annotation.save
      respond_to do |format|
        format.html { redirect_to url_for(@annotated) }
        format.js { render :layout => false }             # annotations/create.rhtml is a bare note div
        format.json { render :json => @annotation.to_json }
      end
    else
      find_note_types
      respond_to do |format|
        format.html { render :action => 'new' }
        format.js { render :action => 'new', :layout => 'inline' }
        format.json { render :json => {:errors => @node.errors}.to_json }
      end
    end
  end
  
  def update
    @annotation = Annotation.find(params[:id])
    @annotation.attributes = params[:annotation]
    @annotation.save!
    respond_to do |format|
      format.html { redirect_to url_for(@annotation) }
      format.js { render :layout => false }             # annotations/update.rhtml is also a bare note div
      format.json { render :json => @annotation.to_json }
    end
  end
  
  protected
  
    def find_annotated
      ref = Kobble.annotated_models.find{ |k| !params[("#{k.to_s}_id").intern].nil? }
      @annotated = ref ? ref.to_s._as_class.find(params[(ref.to_s.underscore + "_id").intern]) : nil
    end
    
    def find_note_types
      @annotation_types = AnnotationType.find(:all, :order => 'name').collect{|at| [at.name, at.id] }
    end

end
