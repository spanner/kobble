class Flag < ActiveRecord::Base
  belongs_to :collection
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'

  # associated polymorphs
  has_many :flaggings
  has_many :flagged, :through => :flaggings

  # associated as polymorph
  has_many :memberships, :as => :member, :dependent => :destroy
  has_many :bundles, :through => :memberships
  has_many :scratches, :as => :scrap, :dependent => :destroy
  has_many :scratchpads, :through => :scratches

end
