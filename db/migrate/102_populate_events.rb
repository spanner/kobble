class PopulateEvents < ActiveRecord::Migration
  def self.up
    [Source, Node, Bundle, Occasion, Topic, Post].each do |klass|
      puts "generating events for #{klass}"
      klass.find(:all, :order => 'created_at ASC', :conditions => 'created_at is not null and collection_id is not null').each do |thing|
        # puts "#{thing.id}: #{thing.name}"
        Event.create({
          :affected => thing,
          :user => thing.creator,
          :account => thing.collection.account,
          :collection => thing.collection,
          :affected_name => thing.name,
          :event_type => 'created',
          :at => thing.created_at
        })
        Event.create({
          :affected => thing,
          :user => thing.updater,
          :account => thing.collection.account,
          :collection => thing.collection,
          :affected_name => thing.name,
          :event_type => 'updated',
          :at => thing.updated_at
        }) unless thing.updated_at.nil? || thing.updated_at <= thing.created_at
      end
    end
    [Collection, Account, User].each do |klass|
      # puts "datestamping #{klass.nice_title.pluralize}"
      klass.find(:all).each do |thing|
        puts "#{thing.id}: #{thing.name}"
        thing.last_active_at = thing.events.latest.at unless thing.events.latest.nil?
        thing.save
      end
    end
  end

  def self.down
    Event.delete_all
  end
end
