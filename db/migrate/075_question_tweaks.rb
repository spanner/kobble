class QuestionTweaks < ActiveRecord::Migration
  def self.up
    add_column :questions, :allow_other, :integer, :default => 0
    rename_column :questions, :dull, :quick
  end

  def self.down
    remove_column :questions, :allow_other
    rename_column :questions, :quick, :dull
  end
end
