class RemoveFlags < ActiveRecord::Migration
  def self.up
    drop_table :flaggings
    drop_table :flags
  end

  def self.down
    create_table "flaggings", :force => true do |t|
      t.integer  "flag_id",        :limit => 11
      t.string   "flaggable_type"
      t.integer  "flaggable_id",   :limit => 11
      t.datetime "deleted_at"
    end

    create_table "flags", :force => true do |t|
      t.text     "body"
      t.string   "offender_type",  :limit => 20
      t.integer  "offender_id",    :limit => 11
      t.integer  "user_id",        :limit => 11
      t.string   "warningtype_id"
      t.integer  "created_by",     :limit => 11
      t.integer  "updated_by",     :limit => 11
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "severity",       :limit => 11, :default => 0
      t.datetime "deleted_at"
    end
  end
end
