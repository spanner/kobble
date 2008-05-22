class BetterConsistency < ActiveRecord::Migration
  def self.up
    add_column :tags, :circumstances, :text
    add_column :people, :circumstances, :text
    add_column :bundles, :circumstances, :text
    add_column :bundles, :clip, :string
  end

  def self.down
    remove_column :tags, :circumstances
    remove_column :people, :circumstances
    remove_column :bundles, :circumstances
    remove_column :bundles, :clip
  end
end
