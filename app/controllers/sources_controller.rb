class SourcesController < CollectionScopedController
  
  skip_before_filter :require_collection, :only => [:upload, :describe]
  before_filter :request_collection, :only => [:upload, :describe]
  
  def upload
    if request.post?
      @source = Source.new(:name => params[:Filename], :collection_id => params[:collection_id])
      @source.uploaded_file = params[:Filedata]
      @source.save!
      render :nothing => true                                                             # SWFupload only cares about response status
    end
  rescue => e
    logger.warn "%%% file upload error: #{e.inspect}"
    render :nothing => true, :status => 500                                               # SWFupload only cares about response status
  end
    
  def describe
    if params[:id]
      @source = Source.find(params[:id])
    elsif params[:upload]
      file_name = params[:upload].strip.gsub(/[^\w\d\.\-]+/, '_')                         # copied from paperclip to match filename processing on upload
      @source = Source.find_by_name(file_name)
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
