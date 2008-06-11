class PeopleController < ApplicationController

  def new
    @person = Person.new
    @person.tags << Tag.from_list(params[:tag_list]) if params[:tag_list]
    @person.collection = Collection.find(params[:collection_id]) if params[:collection_id]
    respond_to do |format|
      format.html
      format.js { render :layout => 'inline' }
    end
  end
  
  def create
    @person = Person.new(params[:person])
    @person.collection ||= Collection.find(params[:collection_id]) if params[:collection_id]
    if @person.save
      @person.tags << Tag.from_list(params[:tag_list]) if params[:tag_list]
      respond_to do |format|
        format.html { 
          flash[:notice] = 'Person object successfully created.'
          redirect_to :action => 'show', :id => @person 
        }
        format.js { render :layout => false }
      end
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.js { render :action => 'new', :layout => 'inline' }
        format.json { render :json => @person.to_json }
      end
    end
  end

  def edit
    @person = Person.find(params[:id])
  end

  def update
    @person = Person.find(params[:id])
    if @person.update_attributes(params[:person])
      @person.tags.clear
      @person.tags << Tag.from_list(params[:tag_list])
      
      flash[:notice] = 'Person object successfully updated.'
      redirect_to :action => 'show', :id => @person
    else
      render :action => 'edit'
    end
  end

  def destroy
    Person.find(params[:id]).destroy
    respond_to do |format|
      format.html do
        redirect_to :action => 'list'
      end
      format.js { render :nothing => true }
      format.xml { head 200 }
    end
  end
end
