class Tag < ActiveRecord::Base
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  belongs_to :collection

  has_many_polymorphs :marks, :skip_duplicates => true, :from => [:nodes, :sources, :bundles, :users, :questions, :blogentries]
  
  public  

end

