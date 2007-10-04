class Memberssuperclusters < ActiveRecord::Migration
  def self.up
    create_table :members_superclusters do |table|
      table.column :supercluster_id, :integer
      table.column :member_type, :string, :limit => 20
      table.column :member_id, :integer
    end
  end

  def self.down
    drop_table :members_superclusters
  end
end
