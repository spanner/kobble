require 'active_support'

module Kobble #:nodoc:
  module Kore

    def self.included(base)
      base.class_eval {
        class_inheritable_accessor :material, :material_definitions
        @material = false
        @material_definitions = []
        @catches = []
        extend ClassMethods
      }
    end

    # This is much like an +acts_as+ extension: it consolidates all the shared kobble functionality behind a single (parameterised) call to is_material.
    #
    # :only and :except parameters can be supplied, so eg:
    #
    # is_material :except => :illustration
    #
    # the options are:
    # :collection, :owners, :illustration, :organisation, :description, :annotation, :discussion, :index, :log, :undelete
    #
    # by default all behaviours are created.
  
    module ClassMethods

      # some defaults and helpers

      def is_material?
        false
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

      # the main business of the module is to apply to each class the common machinery of kobble

      def is_material(options={})

        Kobble.object_model(self)

        possible_definitions = [:collection, :owners, :illustration, :file, :organisation, :bookmarking, :description, :annotation, :discussion, :index, :log, :undelete, :selection]
        cattr_accessor possible_definitions.map{|d| "_has_#{d.to_s}".intern }
        
        if options[:except]
          definitions = possible_definitions - Array(options[:except]) 
        elsif options[:only]
          definitions = possible_definitions & Array(options[:only])
        else
          definitions = possible_definitions
        end
        
        self.material = true
        self.material_definitions = definitions
        
        possible_definitions.each do |d|
          send( "_has_#{d.to_s}=".intern, definitions.include?(d))      # note that _has_x doesn't mean that the necesary columns are there, just that they ought to be
        end

        # collection -> attachment to (and usually confinement within) a collection
    
        if definitions.include?(:collection)
          if table_exists? && self.column_names.include?('collection_id')
            belongs_to :collection
            named_scope :in_collection, lambda { |collection| {:conditions => { :collection_id => collection.id }} }
            named_scope :in_collections, lambda { |collections| {:conditions => ["#{table_name}.collection_id in (" + collections.map{'?'}.join(',') + ")"] + collections.map { |c| c.id }} }
          else
            logger.warn("!! #{self.to_s} should belong_to collection but has no collection_id column")
          end
        end
      
        # owners -> standard creator and updater relationships
      
        if definitions.include?(:owners)
          belongs_to :created_by, :class_name => 'User'
          belongs_to :updated_by, :class_name => 'User'
          named_scope :created_by_user, lambda { |user| {:conditions => { :created_by_id => user.id }} }
          if table_exists? && self.column_names.include?('speaker_id')
            belongs_to :speaker, :class_name => 'Person'
            named_scope :spoken_by_person, lambda { |person| {:conditions => { :speaker_id => person.id }} }
          end
        end
      
        # illustration -> attached image file
      
        if definitions.include?(:illustration)
          if table_exists? && self.column_names.include?('image_file_name')
            has_attached_file :image, 
              :path => ":rails_root/public/:class/:attachment/:id/:style/:basename.:extension", 
              :url => "/:class/:attachment/:id/:style/:basename.:extension",
              :styles => { 
                "thumb" => "56x56#",
                "slide" => "135x135#",
                "illustration" => "240x240>",
                "preview" => "750x540>"
              }
          else
            logger.warn("!! #{self.to_s} should be illustrated but lacks necessary image columns")
          end
        end

        # file -> attached document or media file

        if definitions.include?(:file)
          
          # during transition:
          if table_exists? && self.column_names.include?('clip_file_name')
            has_attached_file :clip, 
              :path => ":rails_root/public/:class/:attachment/:id/:basename.:extension",
              :url => "/:class/:attachment/:id/:basename.:extension"
          end
          
          # but this is the real one.
          if table_exists? && self.column_names.include?('file_file_name')
            has_attached_file :file, 
              :path => ":rails_root/public/:class/:attachment/:id/:basename.:extension",
              :url => "/:class/:attachment/:id/:basename.:extension"
              #! here we add the :processors for audio, video and documents
              
          end
        end

        # description -> tagging

        if definitions.include?(:description)
          has_many :taggings, :as => :taggable, :dependent => :destroy
          has_many :tags, :through => :taggings
          self.can_catch( :tag )
          Kobble.described_model(self)
        end
        
        # manipulation -> workbench drag and droppability
        
        if definitions.include?(:bookmarking)
          has_many :bookmarkings, :as => :bookmark, :dependent => :destroy
          has_many :bookmarkers, :through => :bookmarkings, :source => :created_by
          User.can_catch( self.to_s.downcase.intern )
          Kobble.bookmarked_model(self)
        end
        
        # organisation -> bundling
        
        if definitions.include?(:organisation)
          has_many :bundlings, :as => :member, :dependent => :destroy
          has_many :bundles, :through => :bundlings, :source => :superbundle     
          Bundle.can_catch( self.to_s.downcase.intern )
          Bundle.create_accessors_for(self)
          Kobble.organised_model(self)
        end

        # annotation -> attached field notes

        if definitions.include?(:annotation)
          has_many :annotations, :as => :annotated, :dependent => :destroy
          Kobble.annotated_model(self)
        end

        # discussion -> attached topics

        if definitions.include?(:discussion)
          has_many :topics, :as => :referent, :dependent => :destroy, :order => 'topics.created_at DESC'
          Kobble.discussed_model(self)
        end

        # log -> attached events

        if definitions.include?(:log)
          attr_accessor :just_changed
          has_many :logged_events, :class_name => 'Event', :as => :affected, :dependent => :destroy, :order => 'at DESC'
          Kobble.logged_model(self)
        end
      
        # undelete -> acts_as_paranoid
      
        if definitions.include?(:undelete)
          if table_exists? && self.column_names.include?('deleted_at')
            acts_as_paranoid
            attr_accessor :newly_undeleted
            attr_accessor :reassign_to
          else
            logger.warn("!! #{self.to_s} should be paranoid but has no deleted_at column")
          end
        end

        # selection -> some named scopes useful for limiting lists in the interface

        if definitions.include?(:selection)
          named_scope :other_than, lambda {|thing| {:conditions => ['id != ?', thing.id]}}
          named_scope :latest, { :limit => 20, :order => 'created_at DESC' }
          named_scope :latest_few, { :limit => 5, :order => 'created_at DESC' }
          named_scope :latest_many, { :limit => 100, :order => 'created_at DESC' }
          named_scope :changed_since, lambda {|start| { :conditions => ['created_at > ? or updated_at > ?', start, start] } }
          named_scope :created_by, lambda {|user| { :conditions => ['created_by = ?', user.id] } }
        end
      
        # index -> searchability (and also find-like-thisability)
      
        if definitions.include?(:index)
          acts_as_xapian :texts => [:name, :description, :body].select{ |m| column_names.include?(m.to_s) }
          Kobble.indexed_model(self)
        end

        class_eval {
          extend Kobble::Kore::KobbleClassMethods
          include Kobble::Kore::KobbleInstanceMethods
        }
      end
     
    end #classmethods

    module KobbleClassMethods
      def is_material?
        material and not material.nil?
      end
    end
    
    module KobbleInstanceMethods
    
      def nice_title
        self.class.nice_title
      end
      
      def simplified
        {
          :class => self.class.to_s,
          :id => self.id,
          :name => self.name,
          :description => self.description
        }
      end   

      def owned_by
        return self.account if self.respond_to?('account')
        return self.collection.account if self.respond_to?('collection')
        return self.created_by.account if self.respond_to?('created_by')
      end
    
      def has_collection?
        self.respond_to?('collection') && !self.collection.nil?
      end

      def has_source?
        self.respond_to?('source') && !self.source.nil?
      end

      def is_discussable?
        Kobble.discussed_model?(self.class)
      end
      
      def has_topics?
        is_discussable? && topics.count > 0
      end

      def is_taggable?
        Kobble.described_model?(self.class)
      end
    
      def has_tags?
        is_taggable? && tags.any?
      end

      def tag_list
        tags.map {|t| t.name }.uniq.join(', ') if has_tags?
      end

      def has_members?
        respond_to?('members') && self.members.any?
      end
            
      def is_notable?
        Kobble.annotated_model?(self.class)
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

      # for indexing and excerpting purposes:

      def all_notes
        self.has_notes? ? self.annotations.map {|n| n.body }.join(' ') : ''     
      end

      def all_comments

      end
    
      def is_searchable?
        Kobble.indexed_model?(self.class) && self.respond_to?(:xapian_document_term)
      end

      def has_origins?
        (self.respond_to?('source') && source.nil?) && 
        (self.respond_to?('speaker') && speaker.nil?) && 
        (self.respond_to?('created_by') && created_by.nil?) ? false : true
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

      def has_file?
        return true if self.file && ! self.file_file_name.blank?
        return false
      end

      def file_exists?
        self.has_file? && File.file?(self.file.path)
      end

      def file_extension
        self.has_file? ? self.file_file_name.split('.').last : nil
      end

      def is_audio?
        true if self.has_file? && self.file.content_type =~ /^audio/i
      end

      def is_video?
        true if self.has_file? && self.file.content_type =~ /^video/i
      end

      def is_audio_or_video?
        is_audio? or is_video?
      end

      def is_pdf?
        true if has_file? && file.content_type =~ /pdf/i
      end

      def is_doc?
        true if has_file? && file.content_type =~ /msword/i
      end

      def is_xls?
        true if has_file? && file.content_type =~ /excel/i
      end

      def is_ppt?
        true if has_file? && file.content_type =~ /powerpoint/i
      end

      def is_text?
        true unless has_file?
      end

      def file_type
        %w{audio video pdf doc xls ppt text}.detect {|type| self.send("is_#{type}?".intern) }
      end

      def has_image?
        self.respond_to?('image') && !self.image_file_name.blank?
      end

      def image_exists?
        self.has_image? and File.file? self.image.path
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
    
      def is_bundlable?
        Kobble.organised_model?(self.class)
      end
    
      def has_bundles?
        self.is_bundlable? && self.respond_to?('bundles') && self.bundles.count > 0
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
            
      def has_created_by?
        self.respond_to?('created_by') && !self.created_by.nil?
      end
    
      def has_speaker?
        self.respond_to?('speaker') && !self.speaker.nil?
      end

      def has_occasion?
        self.respond_to?('occasion') && !self.occasion.nil?
      end

      def main_person
        return speaker if has_speaker?
        return created_by
      end
    
      def is_logged?
        Kobble.logged_model?(self.class)
      end
    
      def is_new?
        (self.updated_at.nil? || self.updated_at == self.created_at) && Time.now - self.created_at < 1.week && self.logged_events.count <= 1
      end
    
      def last_event_at
        if self.is_logged? 
          self.events.most_recent.empty? ? DateTime.new(0) : self.events.most_recent.first.at
        end
      end
    
      def reassign_associates
        if self.reassign_to && self.reassign_to.is_a?(User)
          counter = 0
          self.class.reassignable_associations.each do |a|
            association = self.class.reflect_on_association(a)
            association.class_name.as_class.find_with_deleted(:all, :conditions => ["#{association.primary_key_name} = ?", self.id]).each do |associate|
              associate.write_attribute(association.primary_key_name, self.reassign_to.id)
              associate.save_with_validation(false)
              counter = counter + 1
            end
          end
        end
      end
    
    end #materialinstancemethods
  end #construction
end #material
