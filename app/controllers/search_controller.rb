class AccountsController < ApplicationController
  layout :choose_layout

  def index
    results
    render :action => 'results'
  end

  def search
    @klass = request.parameters[:controller].to_s._as_class
    @search = Ultrasphinx::Search.new(
      :query => params[:q],
      :page => params[:page] || 1, 
      :per_page => 20,
      :class_names => params[:scope] == 'global' ? nil : @klass
    )
    @search.run
  end
end
