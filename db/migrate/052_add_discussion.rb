class AddDiscussion < ActiveRecord::Migration

  # all of these tables and the associated mvc are adapted from beast
  # where for adapted read ripped out of and crudely grafted onto my shambly machine

  def self.up
    create_table "forums", :force => true do |t|
      t.column "name",             :string
      t.column "description",      :string
      t.column "topics_count",     :integer, :default => 0
      t.column "posts_count",      :integer, :default => 0
      t.column "position",         :integer
      t.column "description_html", :text
      t.column "collection_id",    :integer
      t.column "created_at",       :datetime
      t.column "created_by",       :integer
      t.column "updated_at",       :datetime
      t.column "updated_by",       :integer
    end

    create_table "posts", :force => true do |t|
      t.column "topic_id",         :integer
      t.column "body",             :text
      t.column "forum_id",         :integer
      t.column "body_html",        :text
      t.column "collection_id",    :integer
      t.column "created_at",       :datetime
      t.column "created_by",       :integer
      t.column "updated_at",       :datetime
      t.column "updated_by",       :integer
    end

    add_index "posts", [:forum_id, :created_at], :name => "index_posts_on_forum_id"
    add_index "posts", [:created_by, :created_at], :name => "index_posts_oncreator_id"

    create_table "topics", :force => true do |t|
      t.column "forum_id",         :integer
      t.column "title",            :string
      t.column "hits",             :integer,  :default => 0
      t.column "sticky",           :integer,  :default => 0
      t.column "posts_count",      :integer,  :default => 0
      t.column "replied_at",       :datetime
      t.column "locked",           :boolean,  :default => false
      t.column "replied_by",       :integer
      t.column "last_post_id",     :integer
      t.column "collection_id",    :integer
      t.column "speaker_id",       :integer
      t.column "created_at",       :datetime
      t.column "created_by",       :integer
      t.column "updated_at",       :datetime
      t.column "updated_by",       :integer
      t.column "subject_type",     :string
      t.column "subject_id",       :integer
    end

    add_index :topics, [:forum_id], :name => "index_topics_on_forum_id"
    add_index :topics, [:forum_id, "sticky", "replied_at"], :name => "index_topics_on_sticky_and_replied_at"
    add_index :topics, [:forum_id, "replied_at"], :name => "index_topics_on_forum_id_and_replied_at"

    add_column :users, :posts_count, :integer, :default => 0
    add_column :users, :last_seen_at, :datetime
    add_index :users, [:last_seen_at], :name => "index_users_on_last_seen_at"
  end

  def self.down
    drop_table :forums
    drop_table :posts
    drop_table :topics
    remove_index :users, [:last_seen_at]
    remove_column :users, :last_seen_at
  end
end
