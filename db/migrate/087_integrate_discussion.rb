class IntegrateDiscussion < ActiveRecord::Migration

  # the discussion classes were bodged in from beast during the MLA project, when friendly public-facing chatter
  # was required. now they need to be stripped down and integrated into the rest of the machine.
  # topics are always attached to spoke objects and don't need much other organisation

  def self.up
    rename_column :topics, :title, :name
    remove_column :topics, :hits
    remove_column :topics, :sticky
    remove_column :topics, :locked
    remove_column :posts, :forum_id
    rename_column :topics, :subject_type, :referent_type
    rename_column :topics, :subject_id, :referent_id
  end

  def self.down
    add_column :topics, :name, :title
    add_column :topics, :hits, :integer
    add_column :topics, :sticky, :integer
    add_column :posts, :forum_id, :integer
    rename_column :topics, :referent_type, :subject_type
    rename_column :topics, :referent_id, :subject_id
  end
end
