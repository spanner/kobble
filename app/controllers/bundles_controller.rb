class BundlesController < ApplicationController
  
  def show
    @display = case params['display']
      when "full" then "full"
      when "list" then "list"
      else "thumb"
    end
    @bundle = Bundle.find(params[:id])
  end

  def new
    @bundle = Bundle.new
    @members = []
    @bundle.tags << Tag.from_list(params[:tag_list]) if params[:tag_list]
    if params[:scratchpad_id]
      @expad = Scratchpad.find(:scratchpad_id)
      @members << @expad.scraps
    end
    @members.uniq!
  end

  def create
    @bundle = Bundle.new(params[:bundle])
    if @bundle.save
      members = []
      @bundle.tags << Tag.from_list(params[:tag_list]) if params[:tag_list]
      if params[:scrap]      
        params[:scrap].each do |s|
          input = s.split('_')
          @bundle.members << input[0].camelize.constantize.find(input[1])
        end
      end
      flash[:notice] = 'Bundle was successfully created.'
      redirect_to :controller => 'bundles', :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @bundle = Bundle.find(params[:id])
  end

  def update
    @bundle = Bundle.find(params[:id])
    if @bundle.update_attributes(params[:bundle])
      @bundle.taggings.clear
      @bundle.tags << Tag.from_list(params[:tag_list])
      flash[:notice] = 'Bundle was successfully updated.'
      redirect_to :action => 'show', :id => @bundle
    else
      render :action => 'edit'
    end
  end

  def destroy
    Bundle.find(params[:id]).destroy
    respond_to do |format|
      format.html do
        redirect_to :action => 'list'
      end
      format.js { render :nothing => true }
      format.xml { head 200 }
    end
  end
end
