class Source < ActiveRecord::Base

  acts_as_spoke

  belongs_to :speaker, :class_name => 'User', :foreign_key => 'speaker_id'
  belongs_to :occasion
  has_many :nodes

  file_column :file
  before_save FileCallbacks.new
  acts_as_catcher :tags, :flags
  acts_as_ferret :fields => {
    :name => { :boost => 3 },
    :synopsis => { :boost => 2 },
    :body => { :boost => 1 },
    :notes => {},
    :extracted_text => {},
    :notes => {},
    :synopsis => {},
    :arising => {},
    :observations => {},
    :emotions => {}
  }

  def self.nice_title
    "source"
  end

end
