class AnnotationTypes < ActiveRecord::Migration
  def self.up

    puts "Creating field note categories"

    circ = AnnotationType.new({
      :name => 'circumstance',
      :description => "Contextual information useful for understanding."
    })
    circ.save!
    
    emo = AnnotationType.new({
      :name => 'emotion',
      :description => "Emotions observed in the subject or felt by the observer, or just around."
    })
    emo.save!
    
    obs = AnnotationType.new({
      :name => 'observation',
      :description => "Details, noticings, clues and miscellaneous useful facts."
    })
    obs.save!
    
    cont = AnnotationType.new({
      :name => 'continuation',
      :description => "Matters arising, ideas, contacts, connections to follow up, parallels to explore."
    })
    cont.save!
    
    AnnotationType.new({
      :name => 'clarification',
      :description => "An elucidation that is possible at the time but which may be lost if not recorded."
    }).save!

    AnnotationType.new({
      :name => 'action',
      :description => "Something must be done. Differs from continuation by being practical and tickable."
    }).save!

    
    [Node, Source, Bundle, Person].each do |klass|
      puts "Extracting field notes from #{klass.to_s}"
      klass.find(:all).each do |thing|
        unless thing.circumstances.nil? || thing.circumstances == ''
          thing.annotations.create!(:body => thing.circumstances, :annotation_type => circ, :creator => thing.creator, :updater => thing.updater)
        end
        unless thing.emotions.nil? || thing.emotions == ''
          thing.annotations.create!(:body => thing.emotions, :annotation_type => emo, :creator => thing.creator, :updater => thing.updater)
        end
        unless thing.observations.nil? || thing.observations == ''
          thing.annotations.create!(:body => thing.observations, :annotation_type => obs, :creator => thing.creator, :updater => thing.updater)
        end
        unless thing.arising.nil? || thing.arising == ''
          thing.annotations.create!(:body => thing.arising, :annotation_type => cont, :creator => thing.creator, :updater => thing.updater)
        end
      end
    end
  end

  def self.down
    AnnotationType.delete_all
    Annotation.delete_all
  end
end
