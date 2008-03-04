class Source < ActiveRecord::Base

  acts_as_spoke

  belongs_to :speaker, :class_name => 'User', :foreign_key => 'speaker_id'
  belongs_to :occasion
  has_many :nodes

  file_column :file
  before_save FileCallbacks.new
  acts_as_catcher :tags, :flags

  def self.nice_title
    "source"
  end

end
