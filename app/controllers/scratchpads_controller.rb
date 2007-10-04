class ScratchpadsController < ApplicationController

  def index
    list
    render :action => 'list'
  end

  verify :redirect_to => { :action => :list }

  # ajax add/remove/sort scratchpad items (scraps)
  # all scraps are identified by the string 'class_id'
  
  def scratch
    @pad = Scratchpad.find(params[:id])
    if (@pad && params[:scrap]) then
      @scraps = []
      params[:scrap].split('|').each do |s|
        input = s.split('_')
        @scraps.push(input[0].camelize.constantize.find(input[1]))
      end    
      @pad.scraps << @scraps
    end
    render :layout => false
  end

  def unscratch
    @pad = Scratchpad.find(params[:id])
    if (@pad && params[:scrap]) then
      @scraps = []
      params[:scrap].split('|').each do |s|
        input = s.split('_')
        @scraps.push(input[0].camelize.constantize.find(input[1]))
      end    
      @pad.scraps.delete(@scraps)
    end
    render :layout => false
  end

  def reorder 
     @pad = Scratchpad.find(params[:id]) 
     if (@pad && params[:scraps]) then
       @scraps = []
       params[:scrap].split('|').each do |s|
         input = s.split('_')
         @scraps.push(input[0].camelize.constantize.find(input[1]))
       end    
     end
     @pad.scraps.clear
     @pad.scraps << @scraps
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

  def create # ahah only
    @scratchpad = Scratchpad.new(params[:scratchpad])
    @scratchpad.user ||= session['user']
    @scratchpad.name ||= 'pad'
    if @scratchpad.save!
      flash[:notice] = 'Scratchpad was successfully created.'
      render :action => 'created', :layout => false
    else
      render :action => 'new'
    end
  end

  def edit # ahah only
    @scratchpad = Scratchpad.find(params[:id])
    render :action => 'edit', :layout => false
  end

  def update # ahah only
    @scratchpad = Scratchpad.find(params[:id])
    if @scratchpad.update_attributes(params[:scratchpad])
      render :action => 'updated', :layout => false
    else
      render :action => 'edit'
    end
  end

  def destroy
    Scratchpad.find(params[:id]).destroy
    if request.xml_http_request?
      render :action => 'destroyed', :layout => false
    else 
      redirect_to :action => 'list'
    end
  end
end
