require 'active_support'

module ActiveRecord
  module Acts #:nodoc:
    module SpokeContent #:nodoc:
      
      def self.included(base)
        base.extend(ClassMethods)
      end

      # This +acts_as+ extension consolidates common spoke functionality in one place for dryness.
      #
      # It defines one class method:
      #
      # acts_as_spoke
      #   which creates a set of standard behaviours
      #
      # :only and :except parameters can be supplied, so eg:
      #
      # acts_as_spoke :except => :illustration
      #
      # the options are:
      # :collection, :owners, :illustration, :organisation, :description, :annotation, :discussion, :index, :log, :undelete
      #
      # by default all behaviours are created.
      
      module ClassMethods
        
        def acts_as_spoke(options={})
          possible_definitions = [:collection, :owners, :illustration, :organisation, :description, :annotation, :discussion, :index, :log, :undelete, :selection]
          cattr_accessor possible_definitions.map{|d| "_has_#{d.to_s}".intern }
          
          if options[:except]
            definitions = possible_definitions - Array(options[:except]) 
          elsif options[:only]
            definitions = possible_definitions & Array(options[:only])
          else
            definitions = possible_definitions
          end
        
          possible_definitions.each do |d|
            send( "_has_#{d.to_s}=".intern, definitions.include?(d))      # note that _has_x doesn't mean that the necesary columns are there, just that they ought to be
          end
        
          if definitions.include?(:collection)
            if self.column_names.include?('collection_id')
              belongs_to :collection
              named_scope :in_collection, lambda { |collection| {:conditions => { :collection_id => collection.id }} }
              named_scope :in_collections, lambda { |collections| {:conditions => ["#{table_name}.collection_id in (" + collections.map{'?'}.join(',') + ")"] + collections.map { |c| c.id }} }
              Collection.can_catch(self)
            else
              logger.warn("!! #{self.to_s} should belong_to collection but has no collection_id column")
            end
          end
          
          if definitions.include?(:owners)
            belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
            belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
            named_scope :created_by_user, lambda { |user| {:conditions => { :created_by => user.id }} }
            if column_names.include?('speaker_id')
              belongs_to :speaker, :class_name => 'Person', :foreign_key => 'speaker_id'
              named_scope :spoken_by_person, lambda { |person| {:conditions => { :speaker_id => person.id }} }
            end
          end
          
          if definitions.include?(:illustration)
            if self.column_names.include?('clip')
              file_column :clip
            else
              logger.warn("!! #{self.to_s} should be illustrated but has no clip column")
            end
            if self.column_names.include?('image')
               file_column :image, :magick => { 
                 :versions => { 
                  "thumb" => "56x56!", 
                  "slide" => "135x135!", 
                  "illustration" => "240>", 
                  "preview" => "750x540>" 
                }
              }
            else
              logger.warn("!! #{self.to_s} should be illustrated but has no image column")
            end
          end
          
          if definitions.include?(:description)
            has_many :taggings, :as => :taggable, :dependent => :destroy
            has_many :tags, :through => :taggings
            self.can_catch(Tag)
            self.can_drop(Tag)
            Tag.can_catch(self)
            Spoke::Associations.described_model(self)
          end

          if definitions.include?(:organisation)
            has_many :paddings, :as => :scrap, :dependent => :destroy
            has_many :scratchpads, :through => :paddings       
            Scratchpad.can_catch(self)
            Scratchpad.can_drop(self)
            has_many :bundlings, :as => :member, :dependent => :destroy
            has_many :bundles, :through => :bundlings, :source => :superbundle      
            Bundle.can_catch(self)
            Bundle.can_drop(self)
            Spoke::Associations.organised_model(self)
          end

          if definitions.include?(:annotation)
            has_many :annotations, :as => :annotated, :dependent => :destroy
            self.can_catch(Annotation)
            Spoke::Associations.annotated_model(self)
          end

          if definitions.include?(:discussion)
            has_many :topics, :as => :referent, :dependent => :destroy, :order => 'topics.created_at DESC'
            Spoke::Associations.discussed_model(self)
          end

          if definitions.include?(:log)
            has_many :logged_events, :class_name => 'Event', :as => :affected, :order => 'at DESC'
            Spoke::Associations.logged_model(self)
          end
          
          if definitions.include?(:undelete)
            if self.column_names.include?('deleted_at')
              acts_as_paranoid
              attr_accessor :newly_undeleted
              attr_accessor :reassign_to
            else
              logger.warn("!! #{self.to_s} should be paranoid but has no deleted_at column")
            end
            
          end

          if definitions.include?(:selection)
            named_scope :latest, { :limit => 20, :order => 'created_at DESC' }
            named_scope :latest_few, { :limit => 5, :order => 'created_at DESC' }
            named_scope :latest_many, { :limit => 100, :order => 'created_at DESC' }
            named_scope :changed_since, lambda {|start| { :conditions => ['created_at > ? or updated_at > ?', start, start] } }
            named_scope :created_by, lambda {|user| { :conditions => ['created_by = ?', user.id] } }
          end
          
          if definitions.include?(:index)
            is_indexed :fields => self.index_fields, :concatenate => self.index_concatenation, :conditions => "#{self.table_name}.deleted_at IS NULL or #{self.table_name}.deleted_at > NOW()"
            Spoke::Associations.indexed_model(self)
          end
          
          self.module_eval("include InstanceMethods")
        end
                
        def index_fields
          ['name', 'description', 'body', 'created_at', 'collection_id', 'created_by'].select{ |m| column_names.include?(m) }
        end
        
        def index_concatenation
          sets = []
          sets.push({:association_name => 'annotations', :field => 'body', :as => 'annotations', :conditions => "annotations.deleted_at IS NULL or annotations.deleted_at > NOW()"}) if self._has_annotation
          sets.push({:association_name => 'topics', :field => 'body', :as => 'topics', :conditions => "topics.deleted_at IS NULL or topics.deleted_at > NOW()"}) if self._has_discussion
          sets
        end
        
        def sort_options
          {
            "name" => "name",
            "date" => "created_at DESC",
          }
        end

        def default_sort
          "name"
        end
        
        def per_page
          50
        end
        
        def nice_title
          self.to_s.downcase
        end
         
      end #classmethods
      
      module InstanceMethods

        public
        
        def nice_title
          self.class.nice_title
        end        

        def owned_by
          return self.account if self.respond_to?('account')
          return self.collection.account if self.respond_to?('collection')
          return self.creator.account if self.respond_to?('creator')
        end
        
        def has_collection?
          self.respond_to?('collection') && !self.collection.nil?
        end

        def has_source?
          self.respond_to?('source') && !self.source.nil?
        end

        def is_discussable?
          true if self.class.reflect_on_association(:topics)
        end

        def has_topics?
          is_discussable? && topics.count > 0
        end

        def is_taggable?
          true if self.class.reflect_on_association(:tags)
        end
        
        def has_tags?
          is_taggable? && tags.count > 0
        end

        def tag_list
          tags.map {|t| t.name }.uniq.join(', ') if has_tags?
        end

        def has_members?
          respond_to?('members') && members.count > 0
        end
                
        def is_notable?
          respond_to?('annotations')
        end
        
        def has_notes?
          is_notable? && !self.annotations.empty?
        end
        
        def has_warnings?
          is_notable? && !self.annotations.bad.empty?
        end
        
        def warnings
          self.annotations.bad
        end

        def has_goodnews?
          is_notable? && !self.annotations.good.empty?
        end
        
        def approvals
          self.annotations.good
        end

        def has_origins?
          (self.respond_to?('source') && source.nil?) && 
          (self.respond_to?('speaker') && speaker.nil?) && 
          (self.respond_to?('creator') && creator.nil?) ? false : true
        end

        def has_body?
          self.respond_to?('body') && !self.body.nil? and self.body.length != 0
        end

        def has_description?
          self.respond_to?('description') && !self.description.nil? and self.description.length != 0
        end

        def has_extracted_text?
          self.respond_to?('extracted_text') && !self.extracted_text.nil? and self.extracted_text.length != 0
        end

        def has_image?
          self.respond_to?('image') && !self.image.nil?
        end

        def image_exists?
          self.has_image? and File.file? self.image
        end

        def has_clip?
          self.respond_to?('clip') && !self.clip.nil?
        end
        
        def clip_exists?
          self.has_clip? and File.file? self.clip
        end

        def has_file?
          self.respond_to?('file') && !self.file.nil?
        end
        
        def file_exists?
          self.has_file? and File.file? self.file
        end

        def filetype
          self.has_file? ? self.file_relative_path.split('.').last : nil
        end

        def has_topics?
          self.respond_to?('topics') && self.topics.count > 0
        end

        def has_posts?
          self.respond_to?('posts') && self.posts.count > 0
        end

        def has_monitorships?
          self.respond_to?('monitorships') && self.monitorships.count > 0
        end

        def has_sources?
          self.respond_to?('sources') && self.sources.count > 0
        end

        def has_nodes?
          self.respond_to?('nodes') && self.nodes.count > 0
        end
        
        def has_bundles?
          self.respond_to?('bundles') && self.bundles.count > 0
        end

        def editable_by?(user)
          user && (user.id == created_by || user.admin?)
        end

        def find_some_text
          return description if has_description?
          return body if has_body?
          return extracted_text if has_extracted_text?
          "No text available"
        end
                
        def has_creator?
          self.respond_to?('creator') && !self.creator.nil?
        end
        
        def has_speaker?
          self.respond_to?('speaker') && !self.speaker.nil?
        end
 
        def main_person
          return speaker if has_speaker?
          return creator
        end
        
        def last_event_at
          self.events.most_recent.empty? ? DateTime.new(0) : self.events.most_recent.first.at
        end
        
        def reassign_associates
          logger.warn("@@@@ reassign_to is #{self.reassign_to} and it's a #{self.reassign_to.class}")
          if self.reassign_to && self.reassign_to.is_a?(User)
            logger.warn("@@@@ reassigning")
            counter = 0
            self.class.reassignable_associations.each do |a|
              association = self.class.reflect_on_association(a)
              association.class_name._as_class.find_with_deleted(:all, :conditions => ["#{association.primary_key_name} = ?", self.id]).each do |associate|
                associate.write_attribute(association.primary_key_name, self.reassign_to.id)
                associate.save_with_validation(false)
                counter = counter + 1
              end
              logger.warn("@@@@ #{counter} items reassigned")

            end
          end
        end
        
      end #instancemethods
      
    end #spokecontent
  end #acts
end #ar
