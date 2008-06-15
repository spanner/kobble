class NodesController < ApplicationController
  require 'uri'
  
  def new
    @node = Node.new
    @sources = Source.in_collections(current_collections)
    @people = Person.in_collections(current_collections)
    @source = Source.find(params[:source_id]) if params[:source_id]
    @node.source = @source
    @node.collection = @node.source.collection if @node.source
    @node.speaker = Person.find(params[:speaker_id]) if params[:speaker_id]
    @node.speaker = @node.source.speaker if @node.source && @node.speaker.nil?
    @node.body = URI.unescape(params[:excerpt]) if params[:excerpt]
    @node.playfrom = params[:inat]
    @node.playto = params[:outat]
    respond_to do |format|
      format.html {
        @inline = false
      }
      format.js {   
        @inline = true
        render :layout => 'inline' 
      }
    end
  end
  
  def inline
  end

  def create
    @node = Node.new(params[:node])
    @node.source = Source.find(params[:source_id]) if params[:source_id] and @node.source.nil?
    if @node.save
      @node.tags << Tag.from_list(params[:tag_list])
      flash[:notice] = "Fragment #{@node.name} created."
      respond_to do |format|
        format.html { redirect_to :action => 'show', :id => @node }
        format.js { render :layout => false }         # nodes/create.rhml is a bare <li>
        format.json { render :json => {:created => @node}.to_json }
      end
    else
      respond_to do |format|
        format.html { 
          @inline = false
          render :action => 'new' 
        }
        format.js { 
          @inline = true
          render :action => 'new', :layout => 'inline' 
        }
        format.json { 
          render :json => {:errors => @node.errors}.to_json 
        }
      end
    end
  end
  
  def edit
    @node = Node.find(params[:id])
    @people = Person.in_collections(current_collections)
    @sources = Source.in_collections(current_collections)
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

end
