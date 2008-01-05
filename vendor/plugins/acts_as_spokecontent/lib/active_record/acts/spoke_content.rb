module ActiveRecord
  module Acts #:nodoc:
    module SpokeContent #:nodoc:
      
      def self.included(base)
        base.class_eval "cattr_accessor :bundleable, :taggable, :flaggable, :discussable, :paddable"   # for once we want shared variables among subclasses
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
          definitions = [:collection, :creator, :updater]
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
        end

        def acts_as_organised(options={})
          definitions = [:bundles, :scratchpads, :tags, :flags, :topics]
          if options[:except]
            definitions = definitions - Array(options[:except]) 
          elsif options[:only]
            definitions = definitions & Array(options[:only]) 
          end
        
          if definitions.include?(:bundles)
            self.bundleable ||= []
            self.bundleable.push(self.to_s.underscore.pluralize.intern) 
          end
          if definitions.include?(:scratchpads)
            self.paddable ||= []
            self.paddable.push(self.to_s.underscore.pluralize.intern) 
          end
          if definitions.include?(:tags)
            self.taggable ||= []
            self.taggable.push(self.to_s.underscore.pluralize.intern) 
          end
          if definitions.include?(:flags)
            self.flaggable ||= []
            self.flaggable.push(self.to_s.underscore.pluralize.intern) 
          end
          if definitions.include?(:topics)
            self.discussable ||= []
            self.discussable.push(self.to_s.underscore.pluralize.intern) 
          end
        end
    
        def acts_as_illustrated(options={})
          definitions = [:image, :clip]
          if options[:except]
            definitions = definitions - Array(options[:except]) 
          elsif options[:only]
            definitions = definitions & Array(options[:only]) 
          end
        
          if definitions.include?(:clip)
            file_column :clip
          end
          if definitions.include?(:image)
            file_column :image, :magick => { 
              :versions => { 
                "thumb" => "56x56!", 
                "slide" => "135x135!", 
                "preview" => "750x540>" 
              }
            }
          end
        end
        
      end #classmethods
    end #spokecontent
  end #acts
end #ar
