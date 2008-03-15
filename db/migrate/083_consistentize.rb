class Consistentize < ActiveRecord::Migration

  # for indexing purposes we would prefer all the searchable models to offer the same basic fields:
  # name, body, synopsis, observations, arising, emotions (the latter three being the optional field notes)

  def self.up
    add_column :occasions, :observations, :text
    add_column :occasions, :arising, :text
    add_column :occasions, :emotions, :text
    add_column :occasions, :body, :text
    rename_column :sources, :synopsis, :description
    rename_column :nodes, :synopsis, :description
    rename_column :bundles, :synopsis, :description
  end

  def self.down
    remove_column :occasions, :observations
    remove_column :occasions, :arising
    remove_column :occasions, :emotions
    remove_column :occasions, :body
    rename_column :sources, :description, :synopsis
    rename_column :nodes, :description, :synopsis
    rename_column :bundles, :description, :synopsis
  end
end
