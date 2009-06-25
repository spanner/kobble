class NodesController < CollectionScopedController
  require 'uri'
  
  def new
    @sources = current_collection.sources
    @people = current_collection.people
    @source = current_collection.sources.find(params[:source_id])
    
    @thing = @source.nodes.build params[:node]
    @thing.collection = current_collection
    @thing.body = URI.unescape(params[:excerpt]) if params[:excerpt]
    @thing.playfrom = params[:inat]
    @thing.playto = params[:outat]
    @thing.speaker ||= @thing.source.speaker
    @thing.file_from ||= 'source'

    respond_to do |format|
      format.html { render }
      format.js { render :partial => 'snipper', :layout => false }
    end
  end
  
  def create
    @source = Source.find(params[:source_id])
    @thing = @source.nodes.build(params[:thing])
    @thing.collection = current_collection
    @thing.speaker ||= @thing.source.speaker
    @thing.file_from ||= 'source'
    
    if @thing.save
      @thing.tags << Tag.from_list(params[:tag_list]) if params[:tag_list]
      respond_to do |format|
        format.html {
          flash[:notice] = "Fragment #{@thing.name} created."
          redirect_to :action => 'show', :id => @thing 
        }
        format.js { render :layout => false }         # nodes/create.rhml is a bare <li>
        format.json { render :json => {:created => @thing}.to_json }
      end
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.js { render :partial => 'snipper', :layout => false }
        format.json { render :json => {:errors => @thing.errors}.to_json }
      end
    end
  end

end
