class BundletypesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @bundletype_pages, @bundletypes = paginate :bundletypes, :per_page => 10
  end

  def show
    @bundletype = Bundletype.find(params[:id])
  end

  def new
    @bundletype = Bundletype.new
  end

  def create
    @bundletype = Bundletype.new(params[:bundletype])
    if @bundletype.save
      flash[:notice] = 'Bundletype was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @bundletype = Bundletype.find(params[:id])
  end

  def update
    @bundletype = Bundletype.find(params[:id])
    if @bundletype.update_attributes(params[:bundletype])
      flash[:notice] = 'Bundletype was successfully updated.'
      redirect_to :action => 'show', :id => @bundletype
    else
      render :action => 'edit'
    end
  end

  def destroy
    Bundletype.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
