class SourcesController < ApplicationController
  
  def new
    @source = Source.new
    @source.tags << Tag.from_list(params[:tag_list]) if params[:tag_list]
    @source.collection = Collection.find(params[:collection_id]) if params[:collection_id]
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
  
  def upload
    if request.post?
      logger.warn "!!! file uploaded: #{params[:Filename]}"
      
      @source = Source.new(:name => params[:Filename], :description => 'uploaded', :collection_id => params[:collection_id])
      @source.uploaded_file = params[:Filedata]
      logger.warn "!!! new source: #{@source.inspect}"
      if @source.valid?
        @source.save!
      else
        logger.warn "!!! errors: #{@source.errors}"
      end
      session[:uploads] ||= {}
      session[:uploads][params[:Filename]] = @source.id
      logger.warn "!!! uploads: #{session[:uploads].inspect}"
      render :nothing => true
    end
  rescue => e
    @error = e
    logger.warn "%%% file upload error: #{e.inspect}"
    render :nothing => true, :status => 500                                               # SWFupload only cares about response status
  end
    
  def describe
    # if params[:filename]                                                                  # return value from the upload is to the swf file, not to javascript, so we generally don't have asset id
    #   file_name = params[:filename].strip.gsub(/[^\w\d\.\-]+/, '_')                       # (copied from paperclip to match filename processing on upload)
    #   @source = Source.find_by_asset_file_name(file_name, :order => 'created_at desc')      # but we do have the filename, so we do the best we can with that.
    # else
    #   @asset = Asset.find(params[:id])
    # end
    # if request.put?
    #   @asset.update_attributes!(params[:asset])
    #   render :partial => 'description', :layout => false
    # else
    #   render :partial => 'describe', :layout => false
    # end
  rescue => e
    @error = e
    logger.warn "file description error: #{e.inspect}"
    render :partial => 'upload_error', :layout => false
  end
  
end
