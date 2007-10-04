class Source < ActiveRecord::Base

  belongs_to :user                  # owner
  belongs_to :person                # person represented in material
  has_and_belongs_to_many :people   # others present in material
  has_many :nodes                   # excerpted to
  
  file_column :clip
  file_column :image, :magick => { 
    :versions => { 
      "thumb" => "56x56!", 
      "slide" => "135x135!", 
      "preview" => "750x540>" 
    },
    :store_dir => "ul"
  }

  public 

end
