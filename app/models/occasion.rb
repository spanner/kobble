class Occasion < ActiveRecord::Base

  acts_as_spoke
  has_many :sources, :dependent => :nullify

  validates_presence_of :name, :description, :collection

end
