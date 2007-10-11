class Circumstances < ActiveRecord::Migration
  def self.up
    add_column :sources, :circumstances, :text
  end

  def self.down
    remove_column :sources, :circumstances
  end
end
