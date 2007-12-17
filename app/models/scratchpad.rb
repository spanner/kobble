class Scratchpad < ActiveRecord::Base
  belongs_to :user
  has_many_polymorphs :scraps, :order => 'position', :skip_duplicates => true, :from => [:nodes, :sources, :tags, :bundles, :users, :user_groups, :questions, :answers, :topics, :posts, :blogentries]

  acts_as_catcher :scraps
  
end
