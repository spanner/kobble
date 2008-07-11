class MoreIndexes < ActiveRecord::Migration
  def self.up
    add_index :users, :email, :unique => true
    add_index :events, :at
    add_index :events, :user_id
    add_index :events, [:affected_type, :affected_id]

    add_index :annotations, [:annotated_type, :annotated_id]
    add_index :annotations, :annotation_type_id

    add_index :nodes, :created_by

  end

  def self.down
  end
end
