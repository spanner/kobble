class FileCallbacks

  def before_save(model)
    if model.file_just_uploaded?
      model.extracted_text = extract_text_from(model.file)
      # RAILS_DEFAULT_LOGGER.warn("model.body is #{model.body.size} characters long")
    end
  end

  private

  # file_column corrects or adds extension to match upload content type
  # so here we can assume that the extension is all we need to look at

  def extract_text_from(filepath)
    extension = filepath.split('.').last
    textfile = extension ? filepath.gsub(extension, 'txt') : filepath + ".txt"
    text = ""
    case extension
    when 'pdf'
      text = `pdftotext #{filepath} -`
    when 'doc'
      text = `antiword #{filepath}`
    when 'html'
      ""
    when 'txt'
      ""
    else
      ""
    end
    RAILS_DEFAULT_LOGGER.warn("text is #{text.size} characters long")
    text
  end
  
end

