class SearchesController < ApplicationController

  def show
    if params.include?(:q)
      list
      render :action => "list"
    else
      new
      render :action => "new"
    end
  end
  
  def new
  end
  
  def create
    list
    render :action => "list"
  end

  def list
    perform_search
  end
  
  def gallery
    perform_search
  end  

  def perform_search
    filters = Hash.new
    filters['collection_id'] = params[:collection] || current_collections.map{ |c| c.id }
    filters['created_by'] = params[:creator] if params[:creator]
    @fullsearch = Ultrasphinx::Search.new(
      :query => params[:q],
      :weights => {'name' => 4, 'description' => 3, 'body' => 2},
      :facets => ['collection_id', 'created_by']
    )
    @search = Ultrasphinx::Search.new(
      :query => params[:q],
      :page => params[:page] || 1, 
      :per_page => 30,
      :weights => {'name' => 4, 'description' => 3, 'body' => 2},
      :facets => ['collection_id', 'created_by'],
      :class_names => params[:among],
      :filters => filters
    )
    @fullsearch.run
    @search.excerpt
  end
end
