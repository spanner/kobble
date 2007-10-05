class Source < ActiveRecord::Base

  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by'
  belongs_to :user                  # the speaker or author may or may not have a login
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
