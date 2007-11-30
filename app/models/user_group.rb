class UserGroup < ActiveRecord::Base
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  belongs_to :collection
  has_and_belongs_to_many :questions

  has_many :users, :dependent => :nullify
  has_many :notifiable, :class_name => 'User', :foreign_key => 'user_group_id', :conditions => ['receive_news_email = 1']
  has_many :questionable, :class_name => 'User', :foreign_key => 'user_group_id', :conditions => ['receive_questions_email = 1']
  
end
