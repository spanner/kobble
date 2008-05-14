class EventLog < ActiveRecord::Migration
  def self.up
    create_table :events do |table|
      table.column :affected_id, :integer
      table.column :affected_type, :string
      table.column :affected_name, :string
      table.column :event_type, :string
      table.column :account_id, :integer
      table.column :collection_id, :integer
      table.column :user_id, :integer
      table.column :notes, :text
      table.column :at, :datetime
    end
  end

  def self.down
    drop_table :event_log
  end
end
