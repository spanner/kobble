class Survey < ActiveRecord::Base
  acts_as_spoke :except => :illustration
end
