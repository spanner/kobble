class WarningsController < ApplicationController

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @warning_pages, @warnings = paginate :warnings, :per_page => 10
  end

  def show
    @warning = Warning.find(params[:id])
  end

  def new
    @warning = Warning.new
    {'node' => Node, 'bundle' => Bundle, 'source' => Source, 'person' => Person}.each do |off, klass|
      if (params[off.to_sym])
        @warning.offender = klass.find(params[off.to_sym])
        break
      end
    end
    @warningtype_options = Warningtype.find(:all, :order => 'name').map {|wt| [wt.name, wt.id]}    
  end

  def create
    @warning = Warning.new(params[:warning])
    @warning.user = current_user
    if @warning.save
      flash[:notice] = 'Warning was successfully created.'
      redirect_to :controller => @warning.offender.class.to_s.downcase.pluralize, :action => 'show', :id => @warning.offender
    else
      render :action => 'new'
    end
  end

  def edit
    @warning = Warning.find(params[:id], :include => ['warningtype'])
    @warningtype_options = Warningtype.find(:all, :order => 'name').map {|wt| [wt.name, wt.id]}    
  end

  def update
    @warning = Warning.find(params[:id])
    if @warning.update_attributes(params[:warning])
      flash[:notice] = 'Warning was successfully updated.'
      redirect_to :action => 'show', :id => @warning
    else
      render :action => 'edit'
    end
  end

  def destroy
    Warning.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
