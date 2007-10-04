class Clusterskeywords < ActiveRecord::Migration
  def self.up
      create_table :clusters_keywords do |table|
        table.column :cluster_id, :integer
        table.column :keyword_id, :integer
      end
    end

    def self.down
      drop_table :clusters_keywords
  end
end
