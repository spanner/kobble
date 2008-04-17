class SingularizeTags < ActiveRecord::Migration

  # quick way to get some dedupes
  # (tried porter stemming: much too strong)

  def self.up
    
    Account.find(:all).each do |account|
      seen = Hash.new
      account.tags.each do |tag|
        # STDERR.puts "tag: #{tag.inspect}"
        if (seen[tag.name.downcase.singularize])
          seen[tag.name.downcase.singularize].subsume(tag)
          STDERR.puts "#{tag.name} already seen as #{seen[tag.name.downcase.singularize].name}"
        else
          seen[tag.name.downcase.singularize] = tag
        end
      end
    end
  end

  def self.down
  end
end
