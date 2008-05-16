class NodesController < ApplicationController
  require 'uri'
  
  def new
    @node = Node.new
    @sources = Source.find(:all, :conditions => limit_to_active_collections)
    @people = Person.find(:all, :conditions => limit_to_active_collections)
    @source = Source.find(params[:source_id]) if params[:source_id]
    @node.source = @source
    @node.collection = @node.source.collection if @node.source
    @node.speaker = Person.find(params[:speaker_id]) if params[:speaker_id]
    @node.body = URI.unescape(params[:excerpt]) if params[:excerpt]
    @node.playfrom = params[:inat]
    @node.playto = params[:outat]
    respond_to do |format|
      format.html { }
      format.js { render :action => 'inline', :layout => false }
      format.xml { }
    end
  end
  
  def inline
  end

  def create
    @node = Node.new(params[:node])
    @node.source = Source.find(params[:source_id])
    if @node.save
      @node.tags << Tag.from_list(params[:tag_list])
      respond_to do |format|
        format.html { 
          redirect_to :action => 'show', :id => @node 
          flash[:notice] = "Fragment #{@node.name} created."
        }
        format.js { render :layout => false } # nodes/create.rhml is a bare list item
        format.json { render :json => @node.to_json }
        format.xml { }
      end
    else
      # or what?
      render :action => 'new'
    end
  end
  
  def edit
    @node = Node.find(params[:id])
    @people = Person.find(:all, :conditions => limit_to_active_collections, :order => 'name')
    @sources = Source.find(:all, :conditions => limit_to_active_collections, :order => 'name')
  end

  def update
    @node = Node.find(params[:id])
    if @node.update_attributes(params[:node])
      @node.taggings.clear
      @node.tags << Tag.from_list(params[:tag_list])
      flash[:notice] = 'Node was successfully updated.'
      redirect_to :action => 'show', :id => @node
    else
      flash[:notice] = 'failed to update.'
      render :action => 'edit'
    end
  end

  def destroy
    Node.find(params[:id]).destroy
    respond_to do |format|
      format.html do
        redirect_to :action => 'list'
      end
      format.js { render :nothing => true }
      format.xml { head 200 }
    end
  end

end
