class TagsCollected < ActiveRecord::Migration
  def self.up
    Tag.find(:all).each do |tag|
      tag.tagged.each do |thing|
        case tag.collection
        when thing.collection
        when nil
          tag.collection = thing.collection
          tag.save
        else
          new_tag = tag.clone
          new_tag.collection = thing.collection
          thing.tags.delete(tag)
          thing.tags << new_tag
          puts "  #{tag.name} +> #{thing.collection.abbreviation}"
        end
      end
    end
  end

  def self.down
  end
end
