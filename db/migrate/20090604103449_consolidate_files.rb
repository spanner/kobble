class ConsolidateFiles < ActiveRecord::Migration
  def self.up
    Source.find(:all).each do |source|
      unless source.file_exists?
        source.file = source.clip
        source.clip.clear
        source.save
      end
    end
  end

  def self.down
  end
end
