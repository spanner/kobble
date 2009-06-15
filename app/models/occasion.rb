class Occasion < ActiveRecord::Base

  is_material
  has_many :sources, :dependent => :nullify

  validates_presence_of :name, :collection

end
