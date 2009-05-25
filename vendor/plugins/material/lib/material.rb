module Material
  require 'material/polymorphs'
  require 'material/string_extensions'
  require 'material/catch_response'
  require 'material/catch_error'
  require 'material/catcher'
  require 'material/construction'
  
  String.send :include, Material::StringExtensions
  ActiveRecord::Base.send :include, Material::Catcher
  ActiveRecord::Base.send :include, Material::Construction
  
end #material
