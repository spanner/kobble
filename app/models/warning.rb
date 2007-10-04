class Warning < ActiveRecord::Base
  belongs_to :user
  belongs_to :warningtype 
  has_many_polymorphs :offenders, :from => [:nodes, :people, :sources, :tags, :bundles]
end
