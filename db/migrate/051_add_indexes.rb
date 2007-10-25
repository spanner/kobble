class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index "nodes", [:collection_id], :name => "index_nodes_on_collection"
    add_index "sources", [:collection_id], :name => "index_sources_on_collection"
    add_index "bundles", [:collection_id], :name => "index_bundles_on_collection"
    add_index "users", [:collection_id], :name => "index_users_on_collection"
    add_index "users", [:login], :name => "index_users_on_login"
    add_index "nodes", [:source_id], :name => "index_nodes_on_source"
    add_index "nodes", [:question_id], :name => "index_nodes_on_question"
    add_index "members_superbundles", [:member_type, :member_id], :name => "index_bundle_members"
    add_index "scraps_scratchpads", [:scrap_type, :scrap_id], :name => "index_scratchpad_scraps"
    add_index "marks_tags", [:mark_type, :mark_id], :name => "index_tag_marks"
  end

  def self.down
    remove_index "nodes", [:collection_id]
    remove_index "sources", [:collection_id]
    remove_index "bundles", [:collection_id]
    remove_index "users", [:collection_id]
    remove_index "users", [:login]
    remove_index "nodes", [:source_id]
    remove_index "nodes", [:question_id]
    remove_index "members_superbundles", [:member_type, :member_id]
    remove_index "scraps_scratchpads", [:scrap_type, :scrap_id]
    remove_index "marks_tags", [:mark_type, :mark_id]
  end
end
