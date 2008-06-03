class AnnotationsController < ApplicationController

  # only accessible as nested resource of annotated object
  # and normally only as a jsonised ajax call
  # notes are only displayed on the object page but can be padded and dropped onto other objects, 
  # whereupon they are duplicated, not shared
  
  before_filter :find_annotated
  before_filter :find_note_types, :only => [:new, :edit]
  
  def new
    @note = Annotation.new
    @note.annotated = @annotated
    respond_to do |format|
      format.html { }
      format.js { render :action => 'inline', :layout => false }
      format.json { render :json => @note.to_json }
    end
  end
  
  def create
    @note = Annotation.new(params[:annotation])
    @note.annotated = @annotated
    if @note.save
      respond_to do |format|
        format.html { redirect_to url_for(@annotated) }
        format.js { render :layout => false }             # annotations/create.rhtml is a bare note div
        format.json { render :json => @note.to_json }
      end
    else
      # or what?
      render :action => 'new'
    end
  end
  
  def update
    @note = Annotation.find(params[:id])
    @note.attributes = params[:annotation]
    @note.save!
    respond_to do |format|
      format.html { redirect_to url_for(@note) }
      format.js { render :layout => false }             # annotations/update.rhtml is also a bare note div
      format.json { render :json => @note.to_json }
    end
  end
  
  protected
  
    def find_annotated
      ref = Spoke::Associations.annotated_models.find{ |k| !params[("#{k.to_s}_id").intern].nil? }
      @annotated = ref ? ref.to_s._as_class.find(params[(ref.to_s.underscore + "_id").intern]) : nil
    end
    
    def find_note_types
      @note_types = AnnotationType.find(:all, :order => 'name').collect{|at| [at.name, at.id] }
    end

end
