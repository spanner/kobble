class Scratchpad < ActiveRecord::Base
  belongs_to :user
  has_many_polymorphs :scraps, :order => 'position', :from => [:nodes, :sources, :tags, :bundles, :questions, :answers, :topics, :posts, :blogentries]

  acts_as_catcher :scraps
  
end
