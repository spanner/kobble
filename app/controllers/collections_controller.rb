class CollectionsController < ApplicationController
  layout :choose_layout

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :reallydestroy, :create, :update ],
         :redirect_to => { :action => :list }

  def set_context
    @display = 'list'
  end

  def list
    perpage = params[:perpage] || (@display == 'thumb') ? 100 : 40
    sort = case params[:sort]
      when "name"  then "name"
      when "date" then "date"
      when "name_reverse" then "name DESC"
      when "date_reverse" then "created_at DESC"
      else "name"
    end
    @collections = Collection.find(:all, :order => sort, :page => {:size => perpage, :current => params[:page]})
  end

  def show
    @collection = Collection.find(params[:id])
  end

  def new
    @collection = Collection.new
  end

  def create
    @collection = Collection.new(params[:collection])
    if @collection.save
      flash[:notice] = 'Collection was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @collection = Collection.find(params[:id])
  end

  def update
    @collection = Collection.find(params[:id])
    if @collection.update_attributes(params[:collection])
      flash[:notice] = 'Collection was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @collection = Collection.find(params[:id])
    # shows confirmation page
  end

  def reallydestroy
    @collection = Collection.find(params[:id])
    name = @collection.name
    @collection.destroy
    flash[:notice] = "#{name} collection removed"
    redirect_to :action => 'list'
  end
end
