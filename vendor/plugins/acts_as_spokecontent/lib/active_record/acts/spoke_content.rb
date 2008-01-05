module ActiveRecord
  module Acts #:nodoc:
    module SpokeContent #:nodoc:
      
      def self.included(base)
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
            has_many :bundlings, :as => :bundled, :dependent => :destroy
            has_many :bundles, :through => :bundlings
          end
          if definitions.include?(:scratchpads)
            has_many :paddings, :as => :padded, :dependent => :destroy
            has_many :scratchpads, :through => :paddings
          end
          if definitions.include?(:tags)
            has_many :taggings, :as => :tagged, :dependent => :nullify
            has_many :tags, :through => :taggings
          end
          if definitions.include?(:flags)
            has_many :flaggings, :as => :flagged, :dependent => :nullify
            has_many :flags, :through => :flaggings
          end
          if definitions.include?(:topics)
            has_many :topics, :as => :subject, :dependent => :nullify
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
