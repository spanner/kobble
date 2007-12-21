class Scratchpad < ActiveRecord::Base
  belongs_to :collection, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :user, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  has_many_polymorphs :scraps, :order => 'position', :skip_duplicates => true, :from => [:nodes, :sources, :tags, :bundles, :questions, :answers, :topics, :posts, :blogentries]
  acts_as_catcher :scraps
end
