class Spokechanges < ActiveRecord::Migration
  def self.up
    rename_table(:clusters, :bundles)
    rename_table(:clustertypes, :bundletypes)
    rename_table(:members_superclusters, :members_superbundles)
    rename_table(:keywords, :tags)
    rename_table(:recordings, :sources)
    rename_table(:paddies_scratchpads, :scraps_scratchpads)
    rename_table(:people_recordings, :people_sources)

    rename_column(:scraps_scratchpads, :paddy_id, :scrap_id)
    rename_column(:scraps_scratchpads, :paddy_type, :scrap_type)
    rename_column(:people_sources, :recording_id, :source_id)
    rename_column(:nodes, :recording_id, :source_id)
    rename_column(:members_superbundles, :supercluster_id, :superbundle_id)
  end

  def self.down
    rename_table(:tags, :keywords)
    rename_table(:sources, :recordings)
    rename_table(:scraps_scratchpads, :paddies_scratchpads)

    rename_column(:paddies_scratchpads, :scrap_id, :paddy_id)
    rename_column(:paddies_scratchpads, :scrap_type, :paddy_type)
    rename_column(:people_sources, :source_id, :recording_id)
    rename_column(:nodes, :source_id, :recording_id)
    rename_column(:members_superbundles, :superbundle_id, :supercluster_id)
  end
end
