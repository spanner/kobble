module ActiveRecordExtensions

  def allow_secondary_creation(association)
    define_method "#new_{association}=" do |data|
      self.send("build_#{association}", data)
    end
    before_update do |obj|
      obj.send(association).save if obj.instance_variable_get("@update_#{association}_on_save")
    end
  end

end

ActiveRecord::Base.send :include, ActiveRecordExtensions