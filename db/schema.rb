# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 87) do

  create_table "accounts", :force => true do |t|
    t.integer "user_id"
    t.string  "name"
    t.string  "image"
    t.string  "status"
  end

  create_table "activations", :force => true do |t|
    t.integer "collection_id"
    t.integer "user_id"
    t.integer "active",        :default => 1
  end

  create_table "bundles", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.text     "body"
    t.integer  "collection_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "observations"
    t.text     "emotions"
    t.text     "arising"
    t.string   "image"
    t.text     "description"
  end

  add_index "bundles", ["collection_id"], :name => "index_bundles_on_collection"

  create_table "bundlings", :force => true do |t|
    t.integer "superbundle_id"
    t.integer "member_id"
    t.string  "member_type",    :limit => 20
    t.integer "position"
  end

  add_index "bundlings", ["member_type", "member_id"], :name => "index_bundle_members"

  create_table "collections", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "description"
    t.string   "status",             :limit => 20, :default => "0"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "allow_registration"
    t.text     "invitation"
    t.text     "welcome"
    t.text     "privacy"
    t.string   "abbreviation"
    t.string   "url"
    t.text     "background"
    t.text     "faq"
    t.integer  "blog_forum_id"
    t.integer  "editorial_forum_id"
    t.integer  "survey_forum_ud"
    t.string   "email_from"
    t.integer  "account_id"
  end

  create_table "flaggings", :force => true do |t|
    t.integer "flag_id"
    t.string  "flaggable_type"
    t.integer "flaggable_id"
  end

  create_table "flags", :force => true do |t|
    t.text     "body"
    t.string   "offender_type",  :limit => 20
    t.integer  "offender_id"
    t.integer  "user_id"
    t.string   "warningtype_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "severity",                     :default => 0
  end

  create_table "monitorships", :force => true do |t|
    t.integer "topic_id"
    t.integer "user_id"
    t.boolean "active",   :default => true
  end

  create_table "nodes", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "notes"
    t.text     "body"
    t.integer  "speaker_id"
    t.integer  "source_id"
    t.string   "status"
    t.integer  "rating"
    t.string   "image"
    t.string   "clip"
    t.integer  "playfrom",       :limit => 10, :precision => 10, :scale => 0
    t.integer  "playto",         :limit => 10, :precision => 10, :scale => 0
    t.integer  "keywords_count"
    t.integer  "collection_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "observations"
    t.text     "emotions"
    t.text     "arising"
    t.text     "circumstances"
    t.text     "original_text"
    t.string   "file"
    t.text     "extracted_text"
  end

  add_index "nodes", ["collection_id"], :name => "index_nodes_on_collection"
  add_index "nodes", ["source_id"], :name => "index_nodes_on_source"

  create_table "occasions", :force => true do |t|
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "description"
    t.string   "image"
    t.string   "clip"
    t.integer  "collection_id"
    t.text     "observations"
    t.text     "arising"
    t.text     "emotions"
    t.text     "body"
  end

  create_table "paddings", :force => true do |t|
    t.integer "scratchpad_id"
    t.string  "scrap_type",    :limit => 20
    t.integer "scrap_id"
    t.integer "position"
  end

  add_index "paddings", ["scrap_type", "scrap_id"], :name => "index_scratchpad_scraps"

  create_table "people", :force => true do |t|
    t.string  "name"
    t.string  "image"
    t.string  "clip"
    t.text    "description"
    t.text    "body"
    t.text    "emotions"
    t.text    "observations"
    t.text    "arising"
    t.integer "collection_id"
  end

  create_table "posts", :force => true do |t|
    t.integer  "topic_id"
    t.text     "body"
    t.text     "body_html"
    t.datetime "created_at"
    t.integer  "created_by"
    t.datetime "updated_at"
    t.integer  "updated_by"
  end

  add_index "posts", ["created_at"], :name => "index_posts_on_forum_id"
  add_index "posts", ["created_by", "created_at"], :name => "index_posts_oncreator_id"

  create_table "scratchpads", :force => true do |t|
    t.string   "name"
    t.integer  "created_by"
    t.datetime "created_at"
    t.integer  "updated_by"
    t.datetime "updated_at"
    t.integer  "collection_id"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  create_table "sources", :force => true do |t|
    t.string   "name"
    t.text     "notes"
    t.text     "description"
    t.integer  "speaker_id"
    t.text     "body"
    t.string   "clip"
    t.integer  "duration",       :limit => 10,  :precision => 10, :scale => 0
    t.integer  "rating"
    t.integer  "collection_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "observations"
    t.text     "emotions"
    t.text     "arising"
    t.string   "image"
    t.text     "circumstances"
    t.integer  "occasion_id"
    t.string   "file",           :limit => 355
    t.text     "extracted_text"
  end

  add_index "sources", ["collection_id"], :name => "index_sources_on_collection"

  create_table "taggings", :force => true do |t|
    t.integer "tag_id"
    t.string  "taggable_type", :limit => 20
    t.integer "taggable_id"
  end

  add_index "taggings", ["taggable_type", "taggable_id"], :name => "index_tag_marks"

  create_table "tags", :force => true do |t|
    t.integer  "parent_id"
    t.string   "name"
    t.text     "description"
    t.string   "colour",         :limit => 7
    t.integer  "nodes"
    t.integer  "keywords_count"
    t.integer  "user_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "collection_id"
    t.string   "image"
    t.integer  "account_id"
  end

  create_table "topics", :force => true do |t|
    t.string   "name"
    t.integer  "posts_count",  :default => 0
    t.datetime "replied_at"
    t.boolean  "locked",       :default => false
    t.integer  "replied_by"
    t.integer  "last_post_id"
    t.integer  "speaker_id"
    t.datetime "created_at"
    t.integer  "created_by"
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.string   "subject_type"
    t.integer  "subject_id"
  end

  add_index "topics", ["replied_at"], :name => "index_topics_on_sticky_and_replied_at"
  add_index "topics", ["replied_at"], :name => "index_topics_on_forum_id_and_replied_at"

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 80, :default => "", :null => false
    t.string   "crypted_password",          :limit => 40, :default => "", :null => false
    t.string   "email",                     :limit => 60, :default => "", :null => false
    t.string   "diminutive",                :limit => 40
    t.string   "honorific"
    t.string   "firstname",                 :limit => 40
    t.string   "lastname",                  :limit => 40
    t.string   "salt",                      :limit => 40, :default => "", :null => false
    t.integer  "verified",                                :default => 0
    t.string   "role"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "logged_in_at"
    t.integer  "deleted",                                 :default => 0
    t.datetime "delete_after"
    t.integer  "collection_id"
    t.integer  "status",                                  :default => 10
    t.string   "image"
    t.text     "description"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "activated_at"
    t.string   "activation_code",           :limit => 40
    t.string   "workplace"
    t.string   "phone"
    t.integer  "posts_count",                             :default => 0
    t.datetime "last_seen_at"
    t.string   "postcode"
    t.string   "new_password"
    t.datetime "last_login"
    t.string   "password"
    t.integer  "receive_news_email",                      :default => 1
    t.integer  "receive_html_email"
    t.integer  "subscribe_everything"
    t.integer  "account_id"
    t.integer  "person_id"
  end

  add_index "users", ["collection_id"], :name => "index_users_on_collection"
  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["last_seen_at"], :name => "index_users_on_last_seen_at"

end
