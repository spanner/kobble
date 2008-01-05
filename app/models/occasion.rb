class Occasion < ActiveRecord::Base

  acts_as_spoke
  has_many :sources, :dependent => :nullify

end
