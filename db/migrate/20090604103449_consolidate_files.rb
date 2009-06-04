class ConsolidateFiles < ActiveRecord::Migration
  def self.up
    Source.find(:all).each do |source|
      puts "refiling #{source.name} unless #{source.file_exists?.inspect}"
      unless source.file_exists?
        source.file = source.clip
        source.clip.clear
        source.save
      end
    end
    remove_column :sources, :clip_file_name
    remove_column :sources, :clip_content_type
    remove_column :sources, :clip_file_size
    remove_column :sources, :clip_updated_at
  end

  def self.down
  end
end
