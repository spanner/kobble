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

ActiveRecord::Schema.define(:version => 106) do

  create_table "account_types", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.float    "price_monthly"
    t.float    "price_yearly"
    t.integer  "collections_limit"
    t.integer  "users_limit"
    t.integer  "sources_limit"
    t.boolean  "can_audio"
    t.boolean  "can_video"
    t.boolean  "can_rss"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "space_limit",       :default => 0
  end

  create_table "accounts", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "image"
    t.string   "status"
    t.integer  "account_type_id"
    t.datetime "last_active_at"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "clip"
  end

  create_table "activations", :force => true do |t|
    t.integer "collection_id"
    t.integer "user_id"
    t.boolean "active",        :default => false
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
    t.string   "description"
    t.datetime "deleted_at"
    t.text     "circumstances"
    t.string   "clip"
  end

  add_index "bundles", ["collection_id"], :name => "index_bundles_on_collection"

  create_table "bundlings", :force => true do |t|
    t.integer  "superbundle_id"
    t.integer  "member_id"
    t.string   "member_type",    :limit => 20
    t.integer  "position"
    t.datetime "deleted_at"
  end

  add_index "bundlings", ["member_type", "member_id"], :name => "index_bundle_members"

  create_table "collections", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbreviation"
    t.string   "url"
    t.string   "email_from"
    t.integer  "account_id"
    t.datetime "last_active_at"
    t.datetime "deleted_at"
  end

  create_table "events", :force => true do |t|
    t.integer  "affected_id"
    t.string   "affected_type"
    t.string   "affected_name"
    t.string   "event_type"
    t.integer  "account_id"
    t.integer  "collection_id"
    t.integer  "user_id"
    t.text     "notes"
    t.datetime "at"
  end

  create_table "flaggings", :force => true do |t|
    t.integer  "flag_id"
    t.string   "flaggable_type"
    t.integer  "flaggable_id"
    t.datetime "deleted_at"
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
    t.datetime "deleted_at"
  end

  create_table "monitorships", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "user_id"
    t.boolean  "active",     :default => false
    t.datetime "deleted_at"
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
    t.datetime "deleted_at"
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
    t.string   "name"
    t.string   "image"
    t.string   "clip"
    t.text     "description"
    t.text     "body"
    t.text     "emotions"
    t.text     "observations"
    t.text     "arising"
    t.integer  "collection_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.text     "address"
    t.string   "postcode"
    t.string   "phone"
    t.string   "honorific"
    t.string   "workplace"
    t.string   "role"
    t.datetime "deleted_at"
  end

  create_table "permissions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "collection_id"
    t.boolean  "admin",         :default => false
    t.boolean  "active",        :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "posts", :force => true do |t|
    t.integer  "topic_id"
    t.text     "body"
    t.integer  "collection_id"
    t.datetime "created_at"
    t.integer  "created_by"
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.datetime "deleted_at"
  end

  add_index "posts", ["created_at"], :name => "index_posts_on_forum_id"
  add_index "posts", ["created_by", "created_at"], :name => "index_posts_oncreator_id"

  create_table "preferences", :force => true do |t|
    t.string   "name"
    t.string   "abbr"
    t.text     "description"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scratchpads", :force => true do |t|
    t.string   "name"
    t.integer  "created_by"
    t.datetime "created_at"
    t.integer  "updated_by"
    t.datetime "updated_at"
    t.integer  "collection_id"
    t.text     "body"
    t.string   "color"
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
    t.datetime "deleted_at"
  end

  add_index "sources", ["collection_id"], :name => "index_sources_on_collection"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.string   "taggable_type", :limit => 20
    t.integer  "taggable_id"
    t.datetime "deleted_at"
  end

  add_index "taggings", ["taggable_type", "taggable_id"], :name => "index_tag_marks"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
    t.integer  "account_id"
    t.text     "body"
    t.text     "observations"
    t.text     "emotions"
    t.text     "arising"
    t.datetime "deleted_at"
  end

  create_table "topics", :force => true do |t|
    t.string   "name"
    t.integer  "posts_count",   :default => 0
    t.datetime "replied_at"
    t.integer  "replied_by"
    t.integer  "last_post_id"
    t.integer  "collection_id"
    t.integer  "speaker_id"
    t.datetime "created_at"
    t.integer  "created_by"
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.string   "referent_type"
    t.integer  "referent_id"
    t.text     "body"
    t.datetime "deleted_at"
  end

  add_index "topics", ["replied_at"], :name => "index_topics_on_sticky_and_replied_at"
  add_index "topics", ["replied_at"], :name => "index_topics_on_forum_id_and_replied_at"

  create_table "user_preferences", :force => true do |t|
    t.integer "user_id"
    t.integer "preference_id"
    t.boolean "active",        :default => false
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 80, :default => "", :null => false
    t.string   "crypted_password",          :limit => 40, :default => "", :null => false
    t.string   "email",                     :limit => 60, :default => "", :null => false
    t.string   "diminutive",                :limit => 40
    t.string   "honorific"
    t.string   "salt",                      :limit => 40, :default => "", :null => false
    t.integer  "verified",                                :default => 0
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "logged_in_at"
    t.integer  "deleted",                                 :default => 0
    t.datetime "delete_after"
    t.integer  "status",                                  :default => 10
    t.string   "image"
    t.text     "description"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "activated_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "last_seen_at"
    t.string   "postcode"
    t.string   "new_password"
    t.string   "password"
    t.integer  "receive_news_email",                      :default => 1
    t.integer  "receive_html_email"
    t.integer  "subscribe_everything"
    t.integer  "account_id"
    t.integer  "person_id"
    t.string   "name"
    t.datetime "last_active_at"
    t.datetime "previously_logged_in_at"
    t.datetime "deleted_at"
  end

  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["last_seen_at"], :name => "index_users_on_last_seen_at"

end
