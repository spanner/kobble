class AccountType < ActiveRecord::Base

  is_material :only => [:owners, :undelete]
  has_many :accounts, :order => 'name'
  
  def readable_space_limit
    case self.space_limit.megabytes
    when 1.megabyte..1023.megabytes
      "#{self.space_limit}MB"
    when 1.gigabyte
      "1GB"
    when 1.gigabyte..100.gigabytes
      "#{self.space_limit/1024}GB"
    else
      "unlimited"
    end
  end
  
  
  
  
end
