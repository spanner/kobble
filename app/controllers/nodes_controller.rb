class NodesController < ApplicationController
  require 'uri'
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @display = case params['display']
      when "thumb" then "thumb"
      when "slide" then "slide"
      else "list"
    end
    perpage = params[:perpage] || (@display == 'thumb') ? 100 : 40
    sort = case params[:sort]
      when "name"  then "name"
      when "date" then "date"
      when "name_reverse" then "name DESC"
      when "date_reverse" then "date DESC"
      else "name"
    end

    @nodes = Node.find(:all, :conditions => limit_to_active_collection, :page => {:size => perpage, :sort => sort, :current => params[:page]})
  end

  def show
    if @display != 'list' && @display != 'slide' && @display != 'thumb' 
      @display = 'full'
    end
    @node = Node.find(params[:id])
    @node.tags.uniq!
  end

  def new
    @node = Node.new
    @node.source = Source.find(params[:source]) if params[:source] && params[:source] != ""
    @node.body = URI.unescape(params[:excerpt]) if params[:excerpt]
    @node.playfrom = params[:inat]
    @node.playto = params[:outat]

  	@sourceoptions = Source.find(:all, :order => 'name').map {|u| [u.name, u.id]}    
    @default_person = Person.find(2)
  end

  def create
    @node = Node.new(params[:node])
    if @node.save
      @node.tags << tags_from_list(params[:keyword_list])
      flash[:notice] = 'Segment created.'
      redirect_to :action => 'show', :id => @node
    else
    	@sourceoptions = Source.find(:all, :order => 'name').map {|u| [u.name, u.id]}    
      render :action => 'new'
    end
  end

  def edit
    @node = Node.find(params[:id])
  	@sourceoptions = Source.find(:all, :order => 'name').map {|u| [u.name, u.id]}    
  end

  def update
    @node = Node.find(params[:id])
    if @node.update_attributes(params[:node])
      @node.tags.clear
      @node.tags << tags_from_list(params[:keyword_list])
      flash[:notice] = 'Node was successfully updated.'
      redirect_to :action => 'show', :id => @node
    else
      flash[:notice] = 'failed to update.'
    	@sourceoptions = Source.find(:all, :order => 'name').map {|u| [u.name, u.id]}    
      render :action => 'edit'
    end
  end

  def destroy
    Node.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

end
