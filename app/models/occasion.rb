class Occasion < ActiveRecord::Base

  belongs_to :collection
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  has_many :sources, :dependent => :nullify

  # acts_as_catcher :sources

  file_column :clip
  file_column :image, :magick => { 
    :versions => { 
      "thumb" => "56x56!", 
      "slide" => "135x135!", 
      "preview" => "750x540>" 
    }
  }

end
