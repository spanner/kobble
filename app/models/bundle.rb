class Bundle < ActiveRecord::Base

  belongs_to :user
  belongs_to :bundletype 
  belongs_to :collection

  has_many_polymorphs :members, :as => 'superbundle', :from => [:nodes, :people, :sources, :tags, :bundles]

end
