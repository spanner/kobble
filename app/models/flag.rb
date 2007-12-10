class Flag < ActiveRecord::Base
  belongs_to :collection
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  has_many_polymorphs :flaggings, :skip_duplicates => true, :from => [:nodes, :sources, :bundles, :users, :tags, :questions, :blogentries, :forums, :topics]

  acts_as_catcher :flaggings

end
