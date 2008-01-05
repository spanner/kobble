class Source < ActiveRecord::Base

  acts_as_spoke

  belongs_to :speaker, :class_name => 'User', :foreign_key => 'speaker_id'
  belongs_to :occasion

  file_column :file
  before_save FileCallbacks.new
  # acts_as_catcher :tags, :flags, :nodes

end
