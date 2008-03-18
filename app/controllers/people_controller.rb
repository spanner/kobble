class PeopleController < ApplicationController

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def show
    @person = Person.find(params[:id])
  end

  def new
    @person = Person.new
  end

  def create
    @person = Person.new(params[:person])
    if @person.save
      @person.tags << tags_from_list(params[:tag_list])
      flash[:notice] = 'Person object successfully created.'
      redirect_to :action => 'show', :id => @person
    else
      render :action => 'new'
    end
  end

  def edit
    @person = Person.find(params[:id])
  end

  def update
    @person = Person.find(params[:id])
    if @person.update_attributes(params[:person])
      @person.tags.clear
      @person.tags << tags_from_list(params[:tag_list])
      
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
