class CleanUpTables < ActiveRecord::Migration
  def self.up

    # strange old clutter from past digressions

    remove_columns :users, :postcode, :delete_after, :deleted, :verified, :honorific, :receive_news_email, :receive_html_email, :subscribe_everything
    remove_column :nodes, :status, :rating, :keywords_count, :notes
    remove_column :sources, :rating, :notes
    remove_column :topics, :speaker_id
    remove_column :tags, :user_id
    remove_column :scratchpads, :color
    remove_columns :collections, :url, :email_from

    # field notes now in annotations table
    
    add_column :occasions, :circumstances, :text  #lazy!
    [:nodes, :sources, :occasions, :bundles, :tags, :people].each do |table|
      remove_columns table, :emotions, :circumstances, :observations, :arising
    end
  end

  def self.down
    add_column :users, :postcode, :string
    add_column :users, :delete_after, :datetime
    add_column :users, :deleted, :integer
    add_column :users, :verified, :integer
    add_column :users, :honorific, :string
    add_column :users, :receive_news_email, :integer
    add_column :users, :receive_html_email, :integer
    add_column :users, :subscribe_everything, :integer
    add_column :nodes, :status, :integer
    add_column :nodes, :rating, :integer
    add_column :nodes, :keywords_count, :integer
    add_column :sources, :rating, :integer
    add_column :sources, :notes, :text
    add_column :topics, :speaker_id, :integer
    add_column :tags, :user_id, :integer
    add_column :scratchpads, :color, :string
    add_column :collections, :url, :string
    add_column :collections, :email_from, :string
    
    [:nodes, :sources, :occasions, :bundles, :tags, :people].each do |table|
      [:emotions, :circumstances, :observations, :arising].each do |column|
        add_column table, column, :text
      end
    end
  end
end
