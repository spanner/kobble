class CollectedAnnotations < ActiveRecord::Migration
  def self.up
    add_column :annotations, :collection_id, :integer
    Annotation.reset_column_information
    Annotation.send :is_material, :only => :collection
    Annotation.find(:all).each do |ann|
      if ann.annotated.nil? || ann.annotated.is_a?(Collection)
        ann.destroy
      else
        ann.get_collection
        ann.save
      end
    end
  end

  def self.down
    remove_column :annotations, :collection_id
  end
end
