class SearchController < ApplicationController
  layout :choose_layout

  def index
    results
    render :action => 'results'
  end

  def results
    @search = Ultrasphinx::Search.new(
      :query => params[:q],
      :page => params[:page] || 1, 
      :per_page => 20,
      :class_names => nil
    )
    @search.run
  end
end
