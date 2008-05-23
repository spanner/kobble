class Source < ActiveRecord::Base

  acts_as_spoke

  belongs_to :occasion
  has_many :nodes, :dependent => :destroy

  file_column :file
  before_save FileCallbacks.new  

  def self.nice_title
    "source"
  end

end
