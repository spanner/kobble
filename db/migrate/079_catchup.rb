class Catchup < ActiveRecord::Migration

  # long period of experimentation and I couldn't be bothered with doing it all through migrations
  # bad bad bad!
  # anyway, here's the amalgamated version

  def self.up
    drop_table :answers
    drop_table :questions
    drop_table :surveys
    drop_table :blogentries
    drop_table :forums
    drop_table :questions_user_groups
    drop_table :user_groups
    remove_column :bundles, :clustertype_id
    remove_column :nodes, :question_id
    remove_column :topics, :forum_id
    remove_column :users, :user_group_id
    remove_column :users, :receive_questions_email
    rename_table :marks_tags, :taggings
    rename_column :taggings, :mark_id, :taggable_id
    rename_column :taggings, :mark_type, :taggable_type
    rename_table :flaggings_flags, :flaggings
    rename_column :flaggings, :flagging_id, :flaggable_id
    rename_column :flaggings, :flagging_type, :flaggable_type
    rename_table :members_superbundles, :bundlings
    rename_table :scraps_scratchpads, :paddings
  end

  def self.down
    raise IrreversibleMigration "this migration drops tables. tables gone."
  end
end
