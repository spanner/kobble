class FixContentTypes < ActiveRecord::Migration
  def self.up
    Source.find(:all).each do |source|
      if source.has_file?
        source.update_attribute(:file_content_type,  MIME::Types.type_for(source.file_file_name).first.to_s)
      end
    end
  end

  def self.down
  end
end
