class PermissionObserver < ActiveRecord::Observer
    
  def after_create(permission)
    STDERR.puts "observing permission creation: collection is #{permission.collection.name}(#{permission.collection.private?}) and user is #{permission.user.name} (#{permission.user.trusted?})"
    permission.active = permission.user.trusted? || permission.collection.public?
    permission.save if permission.changed?
  end
  
end
