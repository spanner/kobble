module SourcesHelper
  def new_source_path_with_session
    session_key = ActionController::Base.session_options[:key]
    new_source_path(session_key => cookies[session_key], :authenticity_token => form_authenticity_token)
  end
  def sources_path_with_session
    session_key = ActionController::Base.session_options[:key]
    sources_path(session_key => cookies[session_key], :authenticity_token => form_authenticity_token)
  end
  def uploader_path_with_session
    session_key = ActionController::Base.session_options[:key]
    uploader_path(session_key => cookies[session_key], :authenticity_token => form_authenticity_token)
  end
end
