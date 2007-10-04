class HelptextsController < ApplicationController

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @helptext_pages, @helptexts = paginate :helptexts, :per_page => 10
  end

  def show
    @helptext = Helptext.find(params[:id])
  end
  
  def for
    if params[:id] and not params[:name]
      render :action => 'show'
    end
    @helptext = Helptext.find(:first, :conditions => ['name = ?', params[:name]])
    render :layout => false
  end

  def new
    @helptext = Helptext.new
  end

  def create
    @helptext = Helptext.new(params[:helptext])
    @helptext.user = session['user']
    if @helptext.save
      flash[:notice] = 'Helptext was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @helptext = Helptext.find(params[:id])
  end

  def update
    @helptext = Helptext.find(params[:id])
    if @helptext.update_attributes(params[:helptext])
      flash[:notice] = 'Helptext was successfully updated.'
      redirect_to :action => 'show', :id => @helptext
    else
      render :action => 'edit'
    end
  end

  def destroy
    Helptext.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
