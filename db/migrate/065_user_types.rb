class UserTypes < ActiveRecord::Migration
  def self.up
    create_table "user_groups" do |t|
      t.column "name",             :string
      t.column "description",      :text
      t.column "prompt",           :string
      t.column "collection_id",    :integer
      t.column "users_count",      :integer, :default => 0
      t.column "created_at",       :datetime
      t.column "created_by",       :integer
      t.column "updated_at",       :datetime
      t.column "updated_by",       :integer
    end
    add_column :users, :user_group_id,  :integer
    add_column :questions, :user_group_id,  :integer
    add_index :users, [:user_group_id], :name => "index_users on group id"
  end

  def self.down
    remove_column :users, :user_group_id
    remove_index :users, [:user_group_id]
    drop_table :user_groups
  end
end
