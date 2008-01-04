class Occasion < ActiveRecord::Base

  acts_as_spoke
  acts_as_organised
  acts_as_illustrated

  has_many :sources, :dependent => :nullify

end
