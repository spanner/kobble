class AnnotationsUndeleteable < ActiveRecord::Migration
  def self.up
    add_column :annotations, :deleted_at, :datetime
  end

  def self.down
    remove_column :annotations, :deleted_at
  end
end
