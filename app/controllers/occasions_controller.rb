class OccasionsController < ApplicationController
  
  # this is user review and management for admins
  # logging in and registration is in account_controller
  
  def new
    @occasion = Occasion.new
    respond_to do |format|
      format.html
      format.js { render :layout => 'inline' }
    end
  end

  def create
    @occasion = Occasion.new(params[:occasion])
    if @occasion.save
      @occasion.tags << Tag.from_list(params[:tag_list]) if params[:tag_list]
      respond_to do |format|
        format.html { 
          flash[:notice] = 'Occasion object successfully created.'
          redirect_to :action => 'show', :id => @occasion 
        }
        format.js { render :layout => false }
        format.json { render :json => @occasion.to_json }
      end
    else
      render :action => 'new'
      
      # or js, json: do what?
    end
  end

  def edit
    @occasion = Occasion.find(params[:id])
  end

  def update
    @occasion = Occasion.find(params[:id])
    if @occasion.update_attributes(params[:occasion])
      @occasion.taggings.clear
      @occasion.tags << Tag.from_list(params[:tag_list])
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
