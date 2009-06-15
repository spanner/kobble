class NodesController < CollectionScopedController
  require 'uri'
  
  def new
    @sources = current_collection.sources
    @people = current_collection.people
    @source = current_collection.sources.find(params[:source_id])
    
    @thing = @source.nodes.build params[:node]
    @thing.body = URI.unescape(params[:excerpt]) if params[:excerpt]
    @thing.playfrom = params[:inat]
    @thing.playto = params[:outat]
    @thing.speaker ||= @thing.source.speaker
    @thing.file_from ||= 'source'

    respond_to do |format|
      format.html { render }
      format.js { render :template => 'snipper', :layout => false }
    end
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
        format.html { render :action => 'new' }
        format.js { render :action => 'new', :layout => 'inline' }
        format.json { render :json => {:errors => @node.errors}.to_json }
      end
    end
  end

end
