class TagFields < ActiveRecord::Migration

  # soon it will matter that everything is equally field-notable

  def self.up
    add_column :tags, :observations, :text
    add_column :tags, :emotions, :text
    add_column :tags, :arising, :text
    remove_column :tags, :collection_id
    remove_column :tags, :parent_id
    remove_column :tags, :colour            #
    remove_column :tags, :nodes             # ancient history
    remove_column :tags, :keywords_count    #
  end

  def self.down
    remove_column :tags, :observations
    remove_column :tags, :emotions
    remove_column :tags, :arising
    add_column :tags, :collection_id, :integer
    add_column :tags, :parent_id, :integer
  end
end
