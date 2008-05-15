class SourcesController < ApplicationController

  def show
    @source = Source.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    @source = Source.find_with_deleted(params[:id])
    render :action => 'restore'
  end

  def new
    @occasions = Occasion.find(:all, :conditions => limit_to_active_collections)
    @people = Person.find(:all, :conditions => limit_to_active_collections)
    @source = Source.new
    @source.tags << Tag.from_list(params[:tag_list]) if params[:tag_list]
  end

  def create
    @source = Source.new(params[:source])
    if @source.save
      @source.tags << Tag.from_list(params[:tag_list])
      flash[:notice] = 'Source object successfully created.'
      redirect_to :action => 'show', :id => @source
    else
      render :action => 'new'
    end
  end

  def edit
    @source = Source.find(params[:id])
    @people = Person.find(:all, :conditions => limit_to_active_collections, :order => 'name')
    @occasions = Occasion.find(:all, :conditions => limit_to_active_collections, :order => 'name')
  end

  def update
    @source = Source.find(params[:id])
    if @source.update_attributes(params[:source])
      @source.taggings.clear
      @source.tags << Tag.from_list(params[:tag_list])
      flash[:notice] = 'Source object successfully updated.'
      redirect_to :action => 'show', :id => @source
    else
      render :action => 'edit'
    end
  end
  
end
