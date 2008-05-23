class Bundle < ActiveRecord::Base

  has_many :bundlings, :dependent => :destroy, :as => 'superbundle'
  acts_as_spoke
  
  def self.nice_title
    "set"
  end
  
  def members
    bundlings.map { |b| b.member }
  end
end

