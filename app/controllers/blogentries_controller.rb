class BlogentriesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    perpage = params[:perpage] || (@display == 'thumb') ? 100 : 40
    sort = "date DESC"
    @blogentries = Blogentry.find(:all, :conditions => limit_to_active_collection, :page => {:size => perpage, :sort => sort, :current => params[:page]})
  end

  def show
    @blogentry = Blogentry.find(params[:id])
  end

  def new
    @blogentry = Blogentry.new
  end

  def create
    @blogentry = Blogentry.new(params[:blogentry])
    if @blogentry.save
      flash[:notice] = 'Blogentry was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @blogentry = Blogentry.find(params[:id])
  end

  def update
    @blogentry = Blogentry.find(params[:id])
    if @blogentry.update_attributes(params[:blogentry])
      flash[:notice] = 'Blogentry was successfully updated.'
      redirect_to :action => 'show', :id => @blogentry
    else
      render :action => 'edit'
    end
  end

  def destroy
    Blogentry.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
