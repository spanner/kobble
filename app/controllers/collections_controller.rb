class CollectionsController < ApplicationController

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :reallydestroy, :create, :update ],
         :redirect_to => { :action => :list }
  
  def index
    list
    render :action => "list"
  end
  
  def set_context
    @scratch = current_user.find_or_create_scratchpads if logged_in?
    EditObserver.current_user = current_user
  end

  def limit_to_active_collections()
    []
  end

  def list
    # this will be the main dashboard view
    # but might get moved to accounts_controller::show

    @collections = current_account.collections
  end
  
  # and the usual crud:
  
  def show
    @collection = Collection.find(params[:id])
    # check permission
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
