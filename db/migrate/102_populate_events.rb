class PopulateEvents < ActiveRecord::Migration
  def self.up
    Event.record_timestamps = false
    [Source, Node, Bundle, Occasion, Topic, Post].each do |klass|
      klass.reset_column_information
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

    Event.record_timestamps = true
    
    [Collection, Account, User].each do |klass|
      puts "datestamping #{klass.nice_title.pluralize}"
      klass.record_timestamps = false
      klass.find(:all).each do |thing|
        puts "#{thing.id}: #{thing.name}"
        thing.last_active_at = thing.events.latest_few.first.at unless thing.events.latest_few.empty?
        thing.save
      end
      klass.record_timestamps = true
    end
  end

  def self.down
    Event.delete_all
  end
end
