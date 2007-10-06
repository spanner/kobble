class Fieldnotes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :observations, :text
    add_column :nodes, :emotions, :text
    add_column :nodes, :arising, :text
    add_column :sources, :observations, :text
    add_column :sources, :emotions, :text
    add_column :sources, :arising, :text
    add_column :bundles, :observations, :text
    add_column :bundles, :emotions, :text
    add_column :bundles, :arising, :text
  end

  def self.down
    remove_column :nodes, :observations
    remove_column :nodes, :emotions
    remove_column :nodes, :arising
    remove_column :sources, :observations
    remove_column :sources, :emotions
    remove_column :sources, :arising
    remove_column :bundles, :observations
    remove_column :bundles, :emotions
    remove_column :bundles, :arising
  end
end
