class MoreSurveying < ActiveRecord::Migration
  def self.up
    add_column :collections, :survey_discussion, :integer
  end

  def self.down
    remove_column :collections, :survey_discussion
  end
end
