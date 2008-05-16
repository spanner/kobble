class ScratchpadsController < ApplicationController

  def new
    @scratchpad = Scratchpad.new
    respond_to do |format|
      format.html {  }
      format.js { render :layout => false }
    end
  end

  def create
    @scratchpad = Scratchpad.new(params[:scratchpad])
    @scratchpad.name ||= 'new pad'
    if @scratchpad.save!
      render :json => @scratchpad.to_json
    end
  end

  def edit
    @scratchpad = Scratchpad.find(params[:id])
    respond_to do |format|
      format.html {  }
      format.js { render :layout => false }
    end
  end

  def update
    @scratchpad = Scratchpad.find(params[:id])
    if @scratchpad.update_attributes(params[:scratchpad])
      render :json => @scratchpad.to_json
    end
  end
    
  def clear
    @scratchpad = Scratchpad.find(params[:id])
    @scratchpad.scraps.clear
    respond_to do |format|
      format.html { render :action => 'show', :id => @scratchpad }
      format.js { render :nothing => true }
    end
  end

  def destroy
    @scratchpad = Scratchpad.find(params[:id])
    @scratchpad.destroy
    respond_to do |format|
      format.html { 
        flash[:notice] = 'Scratchpad removed.'
        redirect_to :back
      }
      format.js { render :nothing => true }
      format.json { render :json => @scratchpad.to_json }
    end
  end
end
