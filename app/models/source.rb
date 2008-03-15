class Source < ActiveRecord::Base

  acts_as_spoke

  belongs_to :speaker, :class_name => 'User', :foreign_key => 'speaker_id'
  belongs_to :occasion
  has_many :nodes

  file_column :file
  before_save FileCallbacks.new
  
  acts_as_catcher :tags, :flags
  acts_as_ferret :single_index => true, 
    :store_class_name => true,
    :fields => {
      :name => { :boost => 3 },
      :synopsis => { :boost => 2 },
      :body => { :boost => 1 },
      :extracted_text => { :boost => 1 },
      :arising => { :boost => 0 },
      :observations => { :boost => 0 },
      :emotions => { :boost => 0 }
    },
    :ferret => {
      :default_field => [:name, :synopsis, :body, :extracted_text, :emotions, :observations, :arising], 
    }

  def self.nice_title
    "source"
  end

end
