class NodesController < ApplicationController
  require 'uri'

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update, :snip ],
         :redirect_to => { :action => :list }

  def show
    @node = Node.find(params[:id])
  end

  def snipper
    @node = Node.new(params[:node])
    render :layout => false
  end

  def snip
    @node = Node.new(params[:node])
    if @node.save
      @node.tags << tags_from_list(params[:tag_list])
      flash[:notice] = 'Snipped!.'
      render :layout => false
    else
      flash[:notice] = 'Snipping failed!.'
    end
  end
  
  def new
    @node = Node.new
    @node.source = Source.find(params[:source]) if params[:source] && params[:source] != ""
    @node.body = URI.unescape(params[:excerpt]) if params[:excerpt]
    @node.playfrom = params[:inat]
    @node.playto = params[:outat]
  end

  def create
    @node = Node.new(params[:node])
    if @node.save
      @node.tags << tags_from_list(params[:tag_list])
      flash[:notice] = 'Segment created.'
      redirect_to :action => 'show', :id => @node
    else
      render :action => 'new'
    end
  end
  
  def edit
    @node = Node.find(params[:id])
  end

  def update
    @node = Node.find(params[:id])
    if @node.update_attributes(params[:node])
      @node.tags.clear
      @node.tags << tags_from_list(params[:tag_list])
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
