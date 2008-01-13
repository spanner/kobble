module ActiveRecord
  module Acts #:nodoc:
    module SpokeContent #:nodoc:
      
      def self.included(base)
        # base.class_eval "cattr_accessor :bundleable_classes, :taggable_classes, :flaggable_classes, :discussable_classes, :paddable_classes"   # for once we want shared variables among subclasses
        base.extend(ClassMethods)
      end

      # This +acts_as+ extension consolidates common spoke functionality in one place for dryness.
      #
      # It defines three class methods:
      #
      # acts_as_spoke
      #   creates the standard ownership and collection relations
      # acts_as_organised
      #   creates the scratchpad, tagging, flagging and discussion links that most objects enjoy
      # acts_as_illustrated
      #   creates the file_column columns for image and clip files
      #
      # :only and :except parameters can be supplied, so eg:
      # acts_as_organised :only => :tags
      # acts_as_illustrated :except => :clip
      #
      # the options are:
      # acts_as_spoke: :collection, :creator, :updater
      # acts_as_organised: :bundles, :scratchpads, :tags, :flags, :topics
      # acts_as_illustrated: :clip, :image
      #
      # by default all relations are created
      #
      # (which means that they're pushed onto class variable arrays that are used to define has_many_polymorphs relations after initialization)
      
      module ClassMethods

        def acts_as_spoke(options={})
          definitions = [:collection, :creator, :updater, :illustration, :discussion]
          if options[:except]
            definitions = definitions - Array(options[:except]) 
          elsif options[:only]
            definitions = definitions & Array(options[:only]) 
          end
        
          if definitions.include?(:collection)
            belongs_to :collection
          end
          if definitions.include?(:creator)
            belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
          end
          if definitions.include?(:updater)
            belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
          end
          if definitions.include?(:illustration)
            file_column :clip
            file_column :image, :magick => { 
              :versions => { 
                "thumb" => "56x56!", 
                "slide" => "135x135!", 
                "preview" => "750x540>" 
              }
            }
          end
          if definitions.include?(:discussion)
            has_many :topics, :as => :subject
          end

          self.class_eval("include InstanceMethods")
        end

        def organised_classes(options={})
          oc = [:sources, :nodes, :bundles, :tags, :flags, :occasions, :forums, :topics, :posts, :questions, :answers, :blogentries, :users, :user_groups]
          if options[:except]
            oc -= Array(options[:except]) 
          elsif options[:only]
            oc &= Array(options[:only]) 
          end
          oc
        end       
        
        def sort_options
          {
            "name" => "name",
            "date created" => "created_at",
            "date modified" => "updated_at",
          }
        end

        def default_sort
          "name"
        end
        
        def nice_title
          self.to_s.downcase
        end
         
      end #classmethods
      
      module InstanceMethods
        
        public
        
        def has_tags?
          self.respond_to?('tags') && self.tags.count > 0
        end

        def tag_list
          self.respond_to?('tags') && tags.map {|t| t.name }.uniq.join(', ')
        end

        def has_members?
          self.respond_to?('members') && self.members.count > 0
        end
        
        def has_circumstances?
          self.respond_to?('circumstances') && !self.circumstances.nil? and self.circumstances.length != 0
        end

        def has_notes?
          (self.respond_to?('observations') && (observations.nil? || observations.size == 0)) && 
          (self.respond_to?('emotions') && (emotions.nil? || emotions.size == 0)) && 
          (self.respond_to?('arising') && (arising.nil? || arising.size == 0)) ? false : true
        end

        def has_origins?
          (self.respond_to?('source') && source.nil?) && 
          (self.respond_to?('creator') && creator.nil?) ? false : true
        end

        def has_synopsis?
          self.respond_to?('synopsis') && !self.synopsis.nil? and self.synopsis.length != 0
        end

        def has_body?
          self.respond_to?('body') && !self.body.nil? and self.body.length != 0
        end

        def has_description?
          self.respond_to?('description') && !self.description.nil? and self.description.length != 0
        end

        def has_synopsis?
          self.respond_to?('synopsis') && !self.synopsis.nil? and self.synopsis.length != 0
        end

        def has_extracted_text?
          self.respond_to?('extracted_text') && !self.extracted_text.nil? and self.extracted_text.length != 0
        end

        def has_image?
          self.respond_to?('image') && !self.image.nil?# and File.file? self.image
        end

        def has_clip?
          self.respond_to?('clip') && !self.clip.nil?# and File.file? self.clip
        end

        def has_file?
          self.respond_to?('file') && !self.file.nil?# and File.file? self.file
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

        def has_marks?
          self.respond_to?('marks') && self.marks.count > 0
        end

        def has_answers?
          self.respond_to?('answers') && self.answers.count > 0
        end

        def editable_by?(user)
          user && (user.id == created_by || user.admin?)
        end

        def find_some_text
          return synopsis if has_synopsis?
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
        
      end #instancemethods
      
    end #spokecontent
  end #acts
end #ar
