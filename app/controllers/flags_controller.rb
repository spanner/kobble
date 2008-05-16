class FlagsController < ApplicationController

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def new
    @flag = Flag.new
  end

  def create
    @flag = Flag.new(params[:flag])
    if @flag.save
      flash[:notice] = 'Flag was successfully created.'
      render :action => 'list'
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
