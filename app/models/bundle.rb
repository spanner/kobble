class Bundle < ActiveRecord::Base

  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  belongs_to :collection
  has_many_polymorphs :members, :as => 'superbundle', :from => [:nodes, :sources, :tags, :bundles, :questions]
  has_many :topics, :as => :subject

  file_column :image, :magick => { 
    :versions => { 
      "thumb" => "56x56!", 
      "slide" => "135x135!", 
      "preview" => "750x540>" 
    }
  }

  def tag_list
    tags.map {|t| t.name }.uniq.join(', ')
  end

end

