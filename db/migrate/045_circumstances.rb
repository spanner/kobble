class Circumstances < ActiveRecord::Migration
  def self.up
    add_column :sources, :circumstances, :text
    add_column :sources, :occasion_id, :integer
  end

  def self.down
    remove_column :sources, :circumstances
    remove_column :sources, :occasion_id
  end
end
