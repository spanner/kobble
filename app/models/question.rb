class Question < ActiveRecord::Base

  belongs_to :collection
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  belongs_to :survey
  has_many :nodes
  acts_as_list :scope => :survey 


  def tag_list
    tags.map {|t| t.name }.uniq.join(', ')
  end

end
