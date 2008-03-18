class UsersToPeople < ActiveRecord::Migration

  # for indexing purposes we would prefer all the searchable models to offer the same basic fields:
  # name, body, synopsis, observations, arising, emotions (the latter three being the optional field notes)

  def self.up
    User.find(:all).each do |u|
      STDERR.puts(u.name)
      columns = Person.column_names - ['id']
      transit = Hash.new
      columns.each {|c| transit[c.intern] = u.send(c) if u.respond_to?(c)}
      p = Person.new(transit)
      p.save!
      Source.find(:all, :conditions => ["speaker_id = ?", u.id]).each do |s|
        s.speaker = p
        s.save
      end
      Node.find(:all, :conditions => ["speaker_id = ?", u.id]).each do |n|
        n.speaker = p
        n.save
      end
      if u.can_login?
        u.person = p
        u.save!
      else
        u.destroy
      end
    end
    
  end

  def self.down
  end
end
