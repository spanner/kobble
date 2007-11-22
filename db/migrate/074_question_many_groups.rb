class QuestionManyGroups < ActiveRecord::Migration
  def self.up
    create_table :questions_user_groups, :id => false do |t|
      t.column "user_group_id",   :integer
      t.column "question_id",     :integer
    end  
    add_index :questions_user_groups, [:user_group_id]
    add_index :questions_user_groups, [:question_id]
    remove_column :questions, :user_group_id
  end

  def self.down
    drop_table :questions_user_groups
    add_column :questions, :user_group_id, :integer
  end
end
