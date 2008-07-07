require 'test/unit'

# This is pretty much guaranteed not to work everywhere... 
# might be time for a plugin_test_helper gem...
require 'rubygems'
require_gem 'rails'
require 'initializer'
puts "Running against Rails #{Rails::VERSION::STRING}"


require 'email_column'

class EmailColumnTest < Test::Unit::TestCase

  def test_validation
    assert EmailColumn.valid?('asdf@example.com')
    assert !EmailColumn.valid?('asdf@example')
    assert !EmailColumn.valid?('example.com')
    assert !EmailColumn.valid?('')
    assert !EmailColumn.valid?(nil)
  end

end
