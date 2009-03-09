require File.dirname(__FILE__) + '/../spec_helper'

describe Source do
  dataset :sources
  test_helper :validations
  
  describe 'validations' do
    before :each do
      @model = Page.new(page_params)
    end

    it 'should require a'
      [:name, :description, :collection].each do |field|
        assert_invalid field, 'required', '', ' ', nil
      end
    end
  end
  
end
