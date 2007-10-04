class WarningtypesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @warningtype_pages, @warningtypes = paginate :warningtypes, :per_page => 10
  end

  def show
    @warningtype = Warningtype.find(params[:id])
  end

  def new
    @warningtype = Warningtype.new
  end

  def create
    @warningtype = Warningtype.new(params[:warningtype])
    if @warningtype.save
      flash[:notice] = 'Warningtype was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @warningtype = Warningtype.find(params[:id])
  end

  def update
    @warningtype = Warningtype.find(params[:id])
    if @warningtype.update_attributes(params[:warningtype])
      flash[:notice] = 'Warningtype was successfully updated.'
      redirect_to :action => 'show', :id => @warningtype
    else
      render :action => 'edit'
    end
  end

  def destroy
    Warningtype.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
