class AnnotationTypes < ActiveRecord::Migration
  def self.up

    puts "Creating field note categories"

    AnnotationType.delete_all
    circ = AnnotationType.new({
      :name => 'Circumstance',
      :description => "Contextual information useful for understanding."
    })
    circ.save!
    
    emo = AnnotationType.new({
      :name => 'Emotional response noticed',
      :description => "Emotions observed in the subject or felt by the observer, or just around."
    })
    emo.save!
    
    obs = AnnotationType.new({
      :name => 'Observation',
      :description => "Details, noticings, clues and miscellaneous useful facts."
    })
    obs.save!
    
    cont = AnnotationType.new({
      :name => 'Action arising',
      :description => "Matters arising, ideas, contacts, connections to follow up, parallels to explore."
    })
    cont.save!
    
    AnnotationType.new({
      :name => 'Clarification or explanation',
      :description => "An elucidation that is possible at the time but which may be lost if not recorded."
    }).save!

    Annotation.delete_all
    Annotation.record_timestamps = false
    [Node, Source, Bundle, Person].each do |klass|
      klass.record_timestamps = false
      puts "Extracting field notes from #{klass.to_s}"
      klass.find(:all).each do |thing|
        unless thing.circumstances.nil? || thing.circumstances.blank?
          thing.annotations.create!(:body => thing.circumstances, :annotation_type => circ, :creator => thing.creator, :updater => thing.updater)
        end
        unless thing.emotions.nil? || thing.emotions.blank?
          thing.annotations.create!(:body => thing.emotions, :annotation_type => emo, :creator => thing.creator, :updater => thing.updater)
        end
        unless thing.observations.nil? || thing.observations.blank?
          thing.annotations.create!(:body => thing.observations, :annotation_type => obs, :creator => thing.creator, :updater => thing.updater)
        end
        unless thing.arising.nil? || thing.arising.blank?
          thing.annotations.create!(:body => thing.arising, :annotation_type => cont, :creator => thing.creator, :updater => thing.updater)
        end
      end
      klass.record_timestamps = true
    end
    Annotation.record_timestamps = true
  end

  def self.down
    AnnotationType.delete_all
    Annotation.delete_all
  end
end
