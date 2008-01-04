class UserGroup < ActiveRecord::Base
  acts_as_spoke
  acts_as_organised
  has_and_belongs_to_many :questions

  has_many :users, :dependent => :nullify
  has_many :users_notifiable, :class_name => 'User', :foreign_key => 'user_group_id', :conditions => ['receive_news_email = 1']
  has_many :users_questionable, :class_name => 'User', :foreign_key => 'user_group_id', :conditions => ['receive_questions_email = 1']

  # acts_as_catcher :users
  
end
