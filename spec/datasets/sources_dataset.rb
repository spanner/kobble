class SourcesDataset < Dataset::Base
  
  def load
    create_source "Testing"
  end
  
  helpers do
    def create_source(name, attributes={})
      create_model :source, name.symbolize, attributes.update(:name => name)
    end
  end
 
end