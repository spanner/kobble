class CollectionFaq < ActiveRecord::Migration
  def self.up
    add_column :collections, :faq, :text
  end

  def self.down
    remove_column :collections, :faq
  end
end
