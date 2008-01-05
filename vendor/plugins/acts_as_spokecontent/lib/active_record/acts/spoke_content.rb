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
        
      end #classmethods
    end #spokecontent
  end #acts
end #ar
