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
      when "listed" then "listed"
      else "thumbs"
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
    @bundle.user = current_user
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

  def addmembers
    @bundle = Bundle.find(params[:id])
    @added = []
    if (params[:node]) then
      params[:node].each do |n|
        node = Node.find(n)
        @bundle.members << node
        @added << node
      end
    end
    if (params[:bundle]) then
      params[:bundle].each do |c|
        bundle = Bundle.find(c)
        
        # this needs to be turned into a proper loop jumper
        if (bundle != @bundle)
          @bundle.members << bundle
          @added << bundle
        end
      end
    end
    render :layout => false
  end

  def removemembers
    @bundle = Bundle.find(params[:id])
    @deleted = []
    if (params[:node]) then
      params[:node].each do |n|
        node = Node.find(n)
        @bundle.members.delete(node)
        @deleted << node
      end
    end
    if (params[:bundle]) then
      params[:bundle].each do |n|
        bundle = Bundle.find(n)
        @bundle.members.delete(bundle)
        @deleted << bundle
      end
    end
    render :layout => false
  end

  def destroy
    Bundle.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
