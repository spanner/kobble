class NotesAsWarnings < ActiveRecord::Migration
  def self.up
    add_column :annotation_types, :badnews, :boolean, :default => false
    add_column :annotation_types, :goodnews, :boolean, :default => false
    add_column :annotations, :important, :boolean, :default => false
    
    AnnotationType.reset_column_information
    AnnotationType.new({
      :name => 'Warning',
      :description => 'These are more administrative: reasons for caution or important caveats, do-not-use markers and so on',
      :badnews => true
    }).save!
    AnnotationType.new({
      :name => 'Approval',
      :description => 'This is a sometimes useful category for greenlighting use of material or marking something as complete',
      :goodnews => true
    }).save!
    
  end

  def self.down
    remove_column :annotation_types, :badnews
    remove_column :annotation_types, :goodnews
    remove_column :annotations, :important
  end
end
