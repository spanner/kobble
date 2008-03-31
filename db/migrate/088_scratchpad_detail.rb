class ScratchpadDetail < ActiveRecord::Migration

  def self.up
    add_column :scratchpads, :body, :text
    add_column :scratchpads, :color, :string
  end

  def self.down
    remove_column :scratchpads, :body
    remove_column :scratchpads, :color
  end
end
