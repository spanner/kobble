class AccountTags < ActiveRecord::Migration

  # for indexing purposes we would prefer all the searchable models to offer the same basic fields:
  # name, body, synopsis, observations, arising, emotions (the latter three being the optional field notes)

  def self.up
    add_column :tags, :account_id, :integer
    remove_column :tags, :collection_id
  end

  def self.down
    remove_column :tags, :account_id
    add_column :tags, :collection_id, :integer
  end
end
