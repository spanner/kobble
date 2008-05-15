class Source < ActiveRecord::Base

  belongs_to :speaker, :class_name => 'Person', :foreign_key => 'speaker_id'
  belongs_to :occasion
  has_many :nodes, :dependent => :destroy

  acts_as_spoke
  acts_as_catcher :tags, :flags

  file_column :file
  before_save FileCallbacks.new  

  def self.nice_title
    "source"
  end

end
