class SourcesController < ApplicationController
  
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
    @source = Source.find(params[:id])
  end

  def new
    @source = Source.new
  end

  def create
    @source = Source.new(params[:source])
    if @source.save
      # @source.tags << tags_from_list(params[:tag_list])
      flash[:notice] = 'Source object successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @source = Source.find(params[:id])
  end

  def update
    @source = Source.find(params[:id])
    if @source.update_attributes(params[:source])
      flash[:notice] = 'Source object successfully updated.'
      redirect_to :action => 'show', :id => @source
    else
      render :action => 'edit'
    end
  end

  def destroy
    Source.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
