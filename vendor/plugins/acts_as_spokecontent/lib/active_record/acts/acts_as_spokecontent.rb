module ActiveRecord; module Acts; end; end 

module ActiveRecord::Acts::Spokecontent
  
  def self.included(base)
    
    STDERR.puts "!!! self #{self} included in base #{base}"
    
    base.class_eval {

      STDERR.puts "!!! in eval self is #{self} and base #{base}"

      def self.acts_as_spoke(options={})
        possibilities = [:collection, :creator, :updater]
        if options[:except]
          possibilities = possibilities - Array(options[:except]) 
        elsif options[:only]
          possibilities = possibilities & Array(options[:only]) 
        end
        
        if possibilities.include?(:collection)
          belongs_to :collection
        end
        if possibilities.include?(:creator)
          belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
        end
        if possibilities.include?(:updater)
          belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
        end
      end

      def self.acts_as_organised(options={})
        possibilities = [:bundles, :scratchpads, :tags, :flags, :topics]
        if options[:except]
          possibilities = possibilities - Array(options[:except]) 
        elsif options[:only]
          possibilities = possibilities & Array(options[:only]) 
        end
        
        if possibilities.include?(:bundles)
          has_many :bundlings, :as => :bundled, :dependent => :destroy
          has_many :bundles, :through => :bundlings
        end
        if possibilities.include?(:scratchpads)
          has_many :paddings, :as => :padded, :dependent => :destroy
          has_many :scratchpads, :through => :paddings
        end
        if possibilities.include?(:tags)
          has_many :taggings, :as => :tagged, :dependent => :nullify
          has_many :tags, :through => :taggings
        end
        if possibilities.include?(:flags)
          has_many :flaggings, :as => :flagged, :dependent => :nullify
          has_many :flags, :through => :flaggings
        end
        if possibilities.include?(:topics)
          has_many :topics, :as => :subject, :dependent => :nullify
        end
      end
    
      def self.acts_as_illustrated(options={})
        possibilities = [:image, :clip]
        if options[:except]
          possibilities = possibilities - Array(options[:except]) 
        elsif options[:only]
          possibilities = possibilities & Array(options[:only]) 
        end
        
        if possibilities.include?(:clip)
          file_column :clip
        end
        if possibilities.include?(:image)
          file_column :image, :magick => { 
            :versions => { 
              "thumb" => "56x56!", 
              "slide" => "135x135!", 
              "preview" => "750x540>" 
            }
          }
        end
      end

    }
        
  end
end
