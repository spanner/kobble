class CollectionsDataset < Dataset::Base
  
  def load
    create_collection "Test"
  end
  
  helpers do
    def create_collection(name, attributes={})
      create_model :collection, name.to_s.downcase.intern, default_collection_params(attributes.update(:name => name))
    end
    
    def default_collection_params(attributes={})
      name = attributes[:name] || 'Test'
      abbreviation = name.downcase[0..3]
      {
        :name => name,
        :abbreviation => abbreviation,
        :description => "Main test collection"
      }.merge(attributes)
    end
  end
 
end