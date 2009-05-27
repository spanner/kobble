module Material
  require 'rubygems'
  gem 'mislav-will_paginate'
  require 'material/polymorphs'
  require 'material/string_extensions'
  require 'material/aap_extensions'
  require 'material/catch_response'
  require 'material/catch_error'
  require 'material/catcher'
  require 'material/core'
  
  String.send :include, Material::StringExtensions
  ActiveRecord::Base.send :include, Material::AapExtensions
  ActiveRecord::Base.send :include, Material::Catcher
  ActiveRecord::Base.send :include, Material::Core
  
end #material
