class Bundle < ActiveRecord::Base

  acts_as_spoke
  has_many_polymorphs :members, :as => 'superbundle', :from => self.organised_classes, :through => :bundlings, :dependent => :destroy
  acts_as_catcher :members
  # acts_as_ferret :single_index => true, 
  #   :store_class_name => true, 
  #   :fields => {
  #     :name => { :boost => 3 },
  #     :synopsis => { :boost => 2 },
  #     :body => { :boost => 1 },
  #     :arising => { :boost => 0 },
  #     :observations => { :boost => 0 },
  #     :emotions => { :boost => 0 }
  #   },
  #   :ferret => {
  #     :default_field => [:name,:synopsis,:body,:emotions,:observations,:arising], 
  #   }

  def self.nice_title
    "set"
  end
end

