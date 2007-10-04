class Person < ActiveRecord::Base
  belongs_to :collection
  has_many :nodes
  has_and_belongs_to_many :sources

  validates_presence_of :name
  validates_presence_of :description
  
  file_column :image, :magick => { 
    :versions => { 
      "thumb" => "56x56!", 
      "slide" => "135x135!", 
      "preview" => "750x540>" 
    }
  }
  
  public

end
