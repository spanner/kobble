class BundlesController < ApplicationController
  
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
      when "date" then "date"
      when "name_reverse" then "name DESC"
      when "date_reverse" then "created_at DESC"
      else "name"
    end

    @bundles = Bundle.find(:all, :conditions => limit_to_active_collection, :order => sort, :page => {:size => perpage, :current => params[:page]})
  end

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
    if params[:scrap]
      params[:scrap].split('|').each do |s|
        input = s.split('_')
        @bundle.members << input[0].camelize.constantize.find(input[1])
      end
    end
    @members.uniq!
  end

  def create
    @bundle = Bundle.new(params[:bundle])
    if @bundle.save
      members = []
      @bundle.tags << tags_from_list(params[:tag_list]) if params[:tag_list]
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
      @bundle.tags.clear
      @bundle.tags << tags_from_list(params[:tag_list])
      flash[:notice] = 'Bundle was successfully updated.'
      redirect_to :action => 'show', :id => @bundle
    else
      render :action => 'edit'
    end
  end

  def add
    @display = case params['display']
      when "full" then "full"
      when "list" then "list"
      else "thumb"
    end
    @bundle = Bundle.find(params[:id])
    @added = []
    if (@bundle && params[:scrap]) then
      params[:scrap].split('|').each do |s|
        input = s.split('_')
        @added.push(input[0].camelize.constantize.find(input[1]))
      end
      @added.uniq!  
      @bundle.members << @added.reject { |s| s == @bundle or @bundle.members.detect {|m| s == m } } 
    end
    render :layout => false
  end

  def remove
    @bundle = Bundle.find(params[:id])
    @deleted = []
    if (@bundle && params[:scrap]) then
      params[:scrap].split('|').each do |s|
        input = s.split('_')
        scrap = input[0].camelize.constantize.find(input[1])
        @bundle.members.delete(scrap) if scrap
        @deleted << scrap
      end
    end
    render :layout => false
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
