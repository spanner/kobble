class SearchesController < ApplicationController

  def show
    if params.any?
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
  
  def perform_search
    models = Kobble.indexed_models.map{|m| m.to_s.classify}
    if params[:only] and models.include?(params[:only])
      @klass = params[:only].as_class 
      models = [params[:only].classify]
    elsif params[:among] && params[:among].any?
      models = models & params[:among]
    end
    
    # add collection scope and make combinable with class scope
    
    @page = params[:page] || 1
    @per_page = params[:per_page] || 100
    models = models.map{|m| m.constantize}
    limits = {:offset => (@page.to_i - 1) * @per_page.to_i, :limit => @per_page.to_i}

    if params[:like]
      cue_klass, cue_id = params[:like].split('_')
      @cue = cue_klass.as_class.find(cue_id) rescue nil
      @search = ActsAsXapian::Similar.new(models, @cue.class == Bundle ? @cue.members.select{|m| m.is_searchable?} : @cue.to_a, limits)
    elsif params[:q]
      @query = params[:q]
      @search = ActsAsXapian::Search.new(models, @query, limits)
    end




  end
end
