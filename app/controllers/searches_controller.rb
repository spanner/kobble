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
    @search = Ultrasphinx::Search.new(
      :query => params[:q],
      :page => params[:page] || 1, 
      :per_page => 20,
      :class_names => params[:among],
      :weights => {'name' => 4, 'description' => 3, 'body' => 2}
    )
    @search.excerpt
  end
end
