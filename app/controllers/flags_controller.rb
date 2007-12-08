class FlagsController < ApplicationController

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    perpage = params[:perpage] || (@display == 'thumb') ? 100 : 40
    @flags = Flag.find(:all, :conditions => limit_to_active_collection, :order => 'name asc', :page => {:size => perpage, :current => params[:page]})
  end

  def show
    @flag = Flag.find(params[:id])
  end

  def new
    @flag = Flag.new
    {'node' => Node, 'bundle' => Bundle, 'source' => Source, 'person' => Person}.each do |off, klass|
      if (params[off.to_sym])
        @flag.flagged = klass.find(params[off.to_sym])
        break
      end
    end
  end

  def create
    @flag = Flag.new(params[:flag])
    if @flag.save
      flash[:notice] = 'Flag was successfully created.'
      redirect_to :controller => @flag.flagged.class.to_s.downcase.pluralize, :action => 'show', :id => @flag.flagged
    else
      render :action => 'new'
    end
  end

  def edit
    @flag = Flag.find(params[:id], :include => ['flagtype'])
  end

  def update
    @flag = Flag.find(params[:id])
    if @flag.update_attributes(params[:flag])
      flash[:notice] = 'Flag was successfully updated.'
      redirect_to :action => 'show', :id => @flag
    else
      render :action => 'edit'
    end
  end

  def destroy
    Flag.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
