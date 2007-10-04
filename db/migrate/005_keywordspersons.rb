class Keywordspersons < ActiveRecord::Migration
  def self.up
    create_table :keywords_people do |table|
      table.column :person_id, :integer
      table.column :keyword_id, :integer
    end
  end

  def self.down
    drop_table :keywords_people
  end
end
