class SearchController < ApplicationController
  layout :choose_layout

  def index
    results
    render :action => 'results'
  end

  def list
    do_search
    render :action => 'results'
  end

  def results
    do_search
  end

  def gallery
    do_search
  end
  
  def do_search
    @search = Ultrasphinx::Search.new(
      :query => params[:q],
      :page => params[:page] || 1, 
      :per_page => 20,
      :class_names => nil
    )
    @search.run
  end

end
