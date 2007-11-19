class QuestionTypes < ActiveRecord::Migration
  def self.up
    add_column :questions, :name, :string
    add_column :questions, :introduction, :text
    add_column :questions, :question_type, :string
    add_column :questions, :request_image, :integer
    add_column :questions, :request_clip, :integer
    add_column :questions, :image, :string
    add_column :questions, :clip, :string
  end

  def self.down
    remove_column :questions, :name
    remove_column :questions, :introduction
    remove_column :questions, :question_type
    remove_column :questions, :request_image
    remove_column :questions, :request_clip
    remove_column :questions, :image
    remove_column :questions, :clip
  end
end
