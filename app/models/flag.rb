class Flag < ActiveRecord::Base

  acts_as_spoke
  acts_as_organised :except => 'flags'

  # associated polymorphs
  has_many :flaggings
  has_many :flaggeds, :through => :flaggings

  # associated as polymorph
  has_many :memberships, :as => :member, :dependent => :destroy
  has_many :bundles, :through => :memberships
  has_many :scratches, :as => :scrap, :dependent => :destroy
  has_many :scratchpads, :through => :scratches

end
