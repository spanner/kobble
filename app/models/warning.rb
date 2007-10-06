class Warning < ActiveRecord::Base
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by'
  has_many_polymorphs :offenders, :from => [:nodes, :sources, :tags, :bundles, :users]
end
