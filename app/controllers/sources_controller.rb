class SourcesController < ApplicationController

  def new
    @occasions = Occasion.in_collections(current_collections)
    @people = Person.in_collections(current_collections)
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
    @people = Person.in_collections(current_collections)
    @occasions = Occasion.in_collections(current_collections)
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
