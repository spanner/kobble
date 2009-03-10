class SourcesDataset < Dataset::Base
  uses :collections
  
  def load
    create_source "Testing", :description => "General purpose testing source."
  end
  
  helpers do
    def create_source(name, attributes={})
      create_model :source, name.to_s.downcase.intern, default_source_params(attributes.update(:name => name))
    end
    
    def default_source_params(attributes={})
      {
        :name => attributes[:name],
        :collection => collections(:test),
        :body => "This would normally be a little bit longer.",
        :description => "Test source"
      }.merge(attributes)
    end
  end
 
end