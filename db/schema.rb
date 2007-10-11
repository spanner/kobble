# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 44) do

  create_table "blogentries", :force => true do |t|
    t.column "created_by",    :integer
    t.column "updated_by",    :integer
    t.column "created_at",    :datetime
    t.column "updated_at",    :datetime
    t.column "name",          :string
    t.column "introduction",  :text
    t.column "body",          :text
    t.column "collection_id", :integer
    t.column "node_id",       :string
    t.column "image",         :string
    t.column "clip",          :string
    t.column "caption",       :text
  end

  create_table "bundles", :force => true do |t|
    t.column "name",           :string
    t.column "user_id",        :integer
    t.column "clustertype_id", :integer
    t.column "body",           :text
    t.column "collection_id",  :integer
    t.column "created_by",     :integer
    t.column "updated_by",     :integer
    t.column "created_at",     :datetime
    t.column "updated_at",     :datetime
    t.column "observations",   :text
    t.column "emotions",       :text
    t.column "arising",        :text
    t.column "image",          :string
    t.column "synopsis",       :string
  end

  create_table "collections", :force => true do |t|
    t.column "user_id",            :integer
    t.column "name",               :string
    t.column "description",        :text
    t.column "status",             :string,   :limit => 20, :default => "0"
    t.column "created_by",         :integer
    t.column "updated_by",         :integer
    t.column "created_at",         :datetime
    t.column "updated_at",         :datetime
    t.column "allow_registration", :integer
    t.column "invitation",         :text
    t.column "welcome",            :text
    t.column "privacy",            :text
    t.column "tag",                :string
    t.column "url",                :string
  end

  create_table "marks_tags", :force => true do |t|
    t.column "tag_id",    :integer
    t.column "mark_type", :string,  :limit => 20
    t.column "mark_id",   :integer
  end

  create_table "members_superbundles", :force => true do |t|
    t.column "superbundle_id", :integer
    t.column "member_id",      :integer
    t.column "member_type",    :string,  :limit => 20
    t.column "position",       :integer
  end

  create_table "nodes", :force => true do |t|
    t.column "name",           :string
    t.column "synopsis",       :text
    t.column "notes",          :text
    t.column "body",           :text
    t.column "speaker_id",     :integer
    t.column "source_id",      :integer
    t.column "status",         :string
    t.column "rating",         :integer
    t.column "image",          :string
    t.column "clip",           :string
    t.column "playfrom",       :integer,  :limit => 10, :precision => 10, :scale => 0
    t.column "playto",         :integer,  :limit => 10, :precision => 10, :scale => 0
    t.column "keywords_count", :integer
    t.column "collection_id",  :integer
    t.column "created_by",     :integer
    t.column "updated_by",     :integer
    t.column "created_at",     :datetime
    t.column "updated_at",     :datetime
    t.column "observations",   :text
    t.column "emotions",       :text
    t.column "arising",        :text
    t.column "question_id",    :integer
  end

  create_table "offenders_warnings", :force => true do |t|
    t.column "warning_id",    :integer
    t.column "offender_type", :string,  :limit => 20
    t.column "offender_id",   :integer
  end

  create_table "questions", :force => true do |t|
    t.column "created_by",    :integer
    t.column "updated_by",    :integer
    t.column "created_at",    :datetime
    t.column "updated_at",    :datetime
    t.column "prompt",        :text
    t.column "guidance",      :text
    t.column "observations",  :text
    t.column "emotions",      :text
    t.column "arising",       :text
    t.column "survey_id",     :integer
    t.column "collection_id", :integer
  end

  create_table "scraps_scratchpads", :force => true do |t|
    t.column "scratchpad_id", :integer
    t.column "scrap_type",    :string,  :limit => 20
    t.column "scrap_id",      :integer
    t.column "position",      :integer
  end

  create_table "scratchpads", :force => true do |t|
    t.column "name",    :string
    t.column "user_id", :integer
  end

  create_table "sessions", :force => true do |t|
    t.column "session_id", :string
    t.column "data",       :text
    t.column "updated_at", :datetime
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  create_table "sources", :force => true do |t|
    t.column "name",          :string
    t.column "notes",         :text
    t.column "synopsis",      :text
    t.column "speaker_id",    :integer
    t.column "body",          :text
    t.column "clip",          :string
    t.column "duration",      :integer,  :limit => 10, :precision => 10, :scale => 0
    t.column "rating",        :integer
    t.column "collection_id", :integer
    t.column "created_by",    :integer
    t.column "updated_by",    :integer
    t.column "created_at",    :datetime
    t.column "updated_at",    :datetime
    t.column "observations",  :text
    t.column "emotions",      :text
    t.column "arising",       :text
    t.column "image",         :string
  end

  create_table "surveys", :force => true do |t|
    t.column "created_by",    :integer
    t.column "updated_by",    :integer
    t.column "created_at",    :datetime
    t.column "updated_at",    :datetime
    t.column "title",         :string
    t.column "description",   :text
    t.column "collection_id", :integer
  end

  create_table "tags", :force => true do |t|
    t.column "parent_id",      :integer
    t.column "name",           :string
    t.column "description",    :text
    t.column "colour",         :string,   :limit => 7
    t.column "nodes",          :integer
    t.column "keywords_count", :integer
    t.column "user_id",        :integer
    t.column "created_by",     :integer
    t.column "updated_by",     :integer
    t.column "created_at",     :datetime
    t.column "updated_at",     :datetime
  end

  create_table "users", :force => true do |t|
    t.column "login",                     :string,   :limit => 80, :default => "",     :null => false
    t.column "crypted_password",          :string,   :limit => 40, :default => "",     :null => false
    t.column "email",                     :string,   :limit => 60, :default => "",     :null => false
    t.column "diminutive",                :string,   :limit => 40
    t.column "honorific",                 :string
    t.column "firstname",                 :string,   :limit => 40
    t.column "lastname",                  :string,   :limit => 40
    t.column "salt",                      :string,   :limit => 40, :default => "",     :null => false
    t.column "verified",                  :integer,                :default => 0
    t.column "role",                      :string
    t.column "remember_token",            :string,   :limit => 40
    t.column "remember_token_expires_at", :datetime
    t.column "created_at",                :datetime
    t.column "updated_at",                :datetime
    t.column "logged_in_at",              :datetime
    t.column "deleted",                   :integer,                :default => 0
    t.column "delete_after",              :datetime
    t.column "collection_id",             :integer
    t.column "status",                    :integer,                :default => 0
    t.column "image",                     :string
    t.column "description",               :text
    t.column "created_by",                :integer
    t.column "updated_by",                :integer
    t.column "type",                      :string,                 :default => "User"
    t.column "activated_at",              :datetime
    t.column "activation_code",           :string,   :limit => 40
    t.column "workplace",                 :string
    t.column "phone",                     :string
  end

  create_table "warnings", :force => true do |t|
    t.column "body",           :text
    t.column "offender_type",  :string,   :limit => 20
    t.column "offender_id",    :integer
    t.column "user_id",        :integer
    t.column "warningtype_id", :string
    t.column "created_by",     :integer
    t.column "updated_by",     :integer
    t.column "created_at",     :datetime
    t.column "updated_at",     :datetime
  end

end
