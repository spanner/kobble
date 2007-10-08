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
      when "date_reverse" then "date DESC"
      else "name"
    end

    @bundles = Bundle.find(:all, :conditions => limit_to_active_collection, :page => {:size => perpage, :sort => sort, :current => params[:page]})
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
    params[:scraps].each do |m|
      fragments = m.split('_', 2)
      if (fragments[0] == 'node')
        @members << Node.find(fragments[1])
      elsif (fragments[0] == 'bundle')
        @members << Bundle.find(fragments[1])
      end
    end
    @members.uniq!
  	@bundletypeoptions = Bundletype.find(:all, :order => 'name').map {|u| [u.name, u.id]}
  end

  def create
    @bundle = Bundle.new(params[:bundle])
    if @bundle.save
      members = []
      params[:members].each do |m|
        fragments = m.split('_', 2)
        if (fragments[0] == 'node')
          members << Node.find(fragments[1])
        elsif (fragments[0] == 'bundle')
          members << Bundle.find(fragments[1])
        end
      end
      logger.debug("members are #{members}")
      @bundle.members << members
      @bundle.tags << tags_from_list(params[:keyword_list])

      flash[:notice] = 'Bundle was successfully created.'
      redirect_to :controller => 'bundles', :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @bundle = Bundle.find(params[:id])
    @members = @bundle.members
  	@bundletypeoptions = Bundletype.find(:all, :order => 'name').map {|u| [u.name, u.id]}
  end

  def update
    @bundle = Bundle.find(params[:id])
    @bundle.nodes = Node.find( params[:nodes] ) if params[:nodes]
    @bundle.tags = tags_from_list(params[:keyword_list])
    if @bundle.update_attributes(params[:bundle])
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
    redirect_to :action => 'list'
  end
end
