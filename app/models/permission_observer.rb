class PermissionObserver < ActiveRecord::Observer
    
  def after_create(permission)
    permission.active = permission.user.trusted? || permission.collection.public?
    permission.save if permission.changed?
  end
  
end
