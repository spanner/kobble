class AddSeqToScrapping < ActiveRecord::Migration
  def self.up
    add_column :scraps_scratchpads, :position, :integer
  end

  def self.down
    remove_column :scraps_scratchpads, :position
  end
end
