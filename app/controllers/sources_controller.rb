class SourcesController < CollectionScopedController
  
  skip_before_filter :require_collection, :only => [:upload, :describe]
  before_filter :request_collection, :only => [:upload, :describe]
  
  def upload
    if request.post?
      @source = Source.new(:name => params[:Filename], :collection_id => params[:collection_id], :occasion_id => params[:occasion_id], :upload_token => params[:FileID])
      @source.uploaded_file = params[:Filedata]                                           # set mime-type from extension
      @source.save!
      @source.tags << Tag.from_list(params[:tag_list]) if params[:tag_list]
      render :nothing => true                                                             # SWFupload only cares about response status
    end
  rescue => e
    logger.warn "%%% file upload error: #{e.inspect}"
    render :nothing => true, :status => 500
  end
    
  def describe
    if params[:id]
      @source = Source.find(params[:id])
    elsif params[:upload]
      @source = Source.find_by_upload_token(params[:upload])
    else
      raise Kobble::Error => "source id or upload parameter required"
    end
    if request.put?
      @source.update_attributes(params[:source])
      @source.taggings.clear
      @source.tags << Tag.from_list(params[:tag_list])
      render :partial => 'description', :layout => false
    else
      render :partial => 'describe', :layout => false
    end
  rescue => e
    @error = e
    logger.warn "%%% file description error: #{e.inspect}"
    render :partial => 'upload_error', :layout => false
  end
  
end
