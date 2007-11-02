class TagsController < ApplicationController

  def index
    list
    render :action => 'list'
  end

  def tree
    @roots = Tag.find(:all,:conditions => [ "parent_id is NULL" ], :order => "name asc" )
  end
  
  def treemap
    @tags = Tag.find(:all, :include => 'nodes')
    @tagtree = {}
    @tags.each do |t|
      if (t.nodes.length && (t.id == 1 || ! t.parent_id.nil?) ) then
        @tagtree[ t.id ] = {
          :label => t.name,
          :parent => t.parent_id,
          :color => t.colour,
          :size => t.marked.length,
        }
      end
    end
  end
  
  def search
    # this needs rewriting to return polymorphic list based on tag overlap

    # if (params[:query])
    #   @tags = []
    #   @query = params[:query]
    #   likestring = "%#{params[:query]}%"
    #   @nodes = Node.find(:all, 
    #     :select => "n.*, count(kwn.keyword_id) as strength",
    #     :joins => "as n 
    #       inner join tags_nodes as kwn on kwn.node_id = n.id
    #       inner join tags as k on kwn.keyword_id = k.id",
    #     :group => "n.id",
    #     :conditions => ["k.name like ?", likestring],
    #     :order => 'strength desc'
    #   )
    # elsif (params[:tags])
    #   @tags = params[:tags].collect { |tid| Tag.find(tid) }
    #   @nodes = Node.find(:all, 
    #     :select => "n.*, count(kwn.keyword_id) as strength",
    #     :joins => "as n inner join tags_nodes as kwn on kwn.node_id = n.id",
    #     :group => "n.id",
    #     :conditions => ["kwn.keyword_id in (?)", params[:tags].join(',')],
    #     :order => 'strength desc'
    #   )
    # else 
    #   @tags = []
    #   @nodes = nil
    # end
  end

  def taglist
    @tags = Tag.find(:all, :include => :parent)
    @kwtree = @tags.collect{ |kw| kw.parentage }
    @kwtree.sort!
    render :layout => false
  end
  
  def matching
    @tags = Tag.find(:all, :conditions => "name like '%#{params[:stem]}%' and collection_id = #{Collection.current_collection.id}").collect {|t| "'#{t.name}'"}
    render :layout => false
  end
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
  
  def list
    sort = case params['sort']
     when "name"  then "name"
     when "date" then "date"
     when "name_reverse" then "name DESC"
     when "date_reverse" then "date DESC"
     else "name ASC"
    end
    perpage = params[:perpage] ? params[:perpage].to_i : 500
    @tags = Tag.find(:all, :conditions => limit_to_active_collection, :page => {:size => perpage, :sort => sort, :current => params[:page]})
  end
  
  def show
    @tag = Tag.find(params[:id])
  end

  def new
    @tag = Tag.new
    @tags = Tag.find(:all, :include => :parent)
    @kwtree = @tags.collect{ |kw| kw.parentage }
    @kwtree.sort!
  end

  def create
    @tag = Tag.new(params[:keyword])
    parentage = params[:parentage].split(':')
    @tag.name = parentage.pop
    if (parentage.nitems > 1)
      @tag.parent = Tag.find(:first, 
                             :select => "kw.*",
                             :conditions => ["kw.name = :parent and kwp.name = :grandparent", {:parent => parentage.pop, :grandparent => parentage.pop}],
                             :joins => "as kw inner join tags as kwp on kw.parent_id = kwp.id")
    elsif (parentage.nitems)
      @tag.parent = Tag.find(:first, 
                             :conditions => ["name = :parent and parent_id is NULL", {:parent => parentage.pop}])
    end
    if @tag.save
      flash[:notice] = 'Keyword was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @tag = Tag.find(params[:id])
    @tags = Tag.find(:all, :include => :parent)
    @tagtree = @tags.collect{ |t| t.parentage }
    @tagtree.sort!
  end

  def update
    @tag = Tag.find(params[:id])
    parentage = params[:parentage].split('/')
    @tag.name = parentage.pop
    if (parentage && parentage.length)
      @tag.parent = Tag.find(:first, :conditions => [ "name = ?", parentage.pop])
    end
    if @tag.update_attributes(params[:tag])
      flash[:notice] = 'Tag was successfully updated.'
      redirect_to :action => 'show', :id => @tag
    else
      render :action => 'edit'
    end
  end

  def destroy
    Tag.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
