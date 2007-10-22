class OccasionsController < ApplicationController
  
  # this is user review and management for admins
  # logging in and registration is in account_controller

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
   perpage = params[:perpage] || (@display == 'thumb') ? 100 : 40
   sort = case params[:sort]
     when "name"  then "name"
     when "date" then "date DESC"
     when "name_reverse" then "name DESC"
     when "date_reverse" then "date"
     else "name"
   end
   @sources = Source.find(:all, :conditions => limit_to_active_collection, :page => {:size => perpage, :sort => sort, :current => params[:page]})
   @display = case params['display']
     when "thumb" then "thumb"
     when "slide" then "slide"
     else "list"
   end
  end
  
  def show
    @occasion = Occasion.find(params[:id])
  end

  def new
    @occasion = Occasion.new
    respond_to do |format|
      format.html
      format.js { render :layout => false, :template => 'occasions/new_inline' }
    end
  end

  def create
    @occasion = Occasion.new(params[:occasion])
    if @occasion.save
      flash[:notice] = 'Occasion created.'
      respond_to do |format|
        format.html
        format.js { render :layout => false, :template => 'occasions/created_inline' }
      end
    else
      render :action => 'new'
    end
  end

  def edit
    @occasion = Occasion.find(params[:id])
  end

  def update
    @occasion = Occasion.find(params[:id])
    if @occasion.update_attributes(params[:occasion])
      flash[:notice] = 'Occasion successfully updated.'
      redirect_to :action => 'show', :id => @occasion
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    Occasion.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
end
