class Scratchpad < ActiveRecord::Base
  belongs_to :user
  has_many_polymorphs :scraps, :order => 'position', :from => [:nodes, :people, :sources, :tags, :bundles]
end
