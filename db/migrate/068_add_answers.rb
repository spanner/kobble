class AddAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers do |t|
      t.column "question_id",      :integer
      t.column "body",             :text
      t.column "image",            :string
      t.column "clip",             :string
      t.column "collection_id",    :integer
      t.column "created_at",       :datetime
      t.column "created_by",       :integer
      t.column "updated_at",       :datetime
      t.column "updated_by",       :integer
      t.column "speaker_id",       :integer
    end
  end

  def self.down
    remove_table :answers
  end
end
