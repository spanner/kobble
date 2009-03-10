require File.dirname(__FILE__) + '/../spec_helper'

describe Source do
  dataset :sources
  
  describe 'validations' do
    before :each do
      @source = sources(:testing)
    end

    it 'should require a name' do
      [:name, :description, :collection].each do |field|
        @source.send("#{field.to_s}=".intern, nil)
        @source.should_not be_valid
      end
    end
    
  end
  
end
