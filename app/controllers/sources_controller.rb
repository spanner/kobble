class SourcesController < CollectedController
    
  def upload
    if request.post?
      @source = Source.new(:name => params[:Filename], :collection_id => params[:collection_id])
      @source.uploaded_file = params[:Filedata]
      @source.save!
      session["upload_#{params[:Filename]}".intern] = @source.id
      logger.warn "    and session is #{session.inspect}"
      render :nothing => true
    end
  rescue => e
    logger.warn "%%% file upload error: #{e.inspect}"
    render :nothing => true, :status => 500                                               # SWFupload only cares about response status
  end
    
  def describe
    if params[:id]
      @source = Source.find(params[:id])
    elsif params[:upload]
      @source = Source.find_by_name(params[:upload])
    else
      raise "source id or upload parameter required"
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
