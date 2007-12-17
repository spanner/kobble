class ScratchpadsController < ApplicationController

  def index
    list
    render :action => 'list'
  end

  verify :redirect_to => { :action => :list }

  # ajax add/remove/sort scratchpad items (scraps)
  # all scraps are identified by the string 'class_id'
  
  def add
    @scratchpad = Scratchpad.find(params[:id])
    if (@scratchpad && params[:scrap]) then
      @scraps = []
      params[:scrap].split('|').each do |s|
        input = s.split('_')
        scrap = input[0].classify.find(input[1])
        @scraps.push(scrap) if scrap
      end    
      @scratchpad.scraps << @scraps
    end
    render :layout => false
  end

  def remove
    @scratchpad = Scratchpad.find(params[:id])
    if (@scratchpad && params[:scrap]) then
      @deleted = []
      params[:scrap].split('|').each do |s|
        input = s.split('_')
        scrap = input[0].classify.find(input[1])
        @deleted.push(scrap) if scrap
      end    
      @scratchpad.scraps.delete(@deleted)
    end
    render :layout => false
  end

  def reorder 
     @scratchpad = Scratchpad.find(params[:id]) 
     if (@scratchpad && params[:scraps]) then
       @scraps = []
       params[:scrap].split('|').each do |s|
         input = s.split('_')
         @scraps.push(input[0].camelize.constantize.find(input[1]))
       end    
     end
     @scratchpad.scraps.clear
     @scratchpad.scraps << @scraps
     render :nothing => true 
   end 

  def emptyscratch
    @pad = Scratchpad.find(params[:id])
    @deleted = @pad.scraps.collect{ |p| "pad_#{p.class.to_s.downcase}_#{p.id}" }
    @pad.scraps.clear
    render :layout => false
  end

  # rest is normal scaffolding

  def list
    @scratchpad_pages, @scratchpads = paginate :scratchpads, :per_page => 100
  end

  def show
    @display = case params['display']
      when "list" then "list"
      when "full" then "full"
      else "thumbs"
    end
    @scratchpad = Scratchpad.find(params[:id])
  end

  def new
    @scratchpad = Scratchpad.new
  end

  def create
    @scratchpad = Scratchpad.new(params[:scratchpad])
    @scratchpad.name ||= 'pad'
    if @scratchpad.save!
      flash[:notice] = 'Scratchpad was successfully created.'
      render :action => 'created', :layout => false
    else
      render :action => 'new'
    end
  end

  def edit
    @scratchpad = Scratchpad.find(params[:id])
    render :action => 'edit', :layout => false
  end

  def update
    @scratchpad = Scratchpad.find(params[:id])
    if @scratchpad.update_attributes(params[:scratchpad])
      render :action => 'updated', :layout => false
    else
      render :action => 'edit'
    end
  end
  
  def toset
    @scratchpad = Scratchpad.find(params[:id])
    @bundle = Bundle.new
    @bundle.name = @scratchpad.name
    @bundle.save!
    @bundle.members << @scratchpad.scraps
    @scratchpad.scraps.clear
    @scratchpad.name = 'empty'
    @scratchpad.save!
    redirect_to :controller => 'bundles', :action => 'show', :id => @bundle
  end
  
  def clear
    @scratchpad = Scratchpad.find(params[:id])
    @scratchpad.scraps.clear
  end

  def destroy
    Scratchpad.find(params[:id]).destroy
    flash[:notice] = 'Scratchpad removed.'
    respond_to do |format|
      format.html { render :action => 'list' }
      format.js { render :nothing => true }
    end
  end
end
