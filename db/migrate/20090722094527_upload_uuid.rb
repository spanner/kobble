class UploadUuid < ActiveRecord::Migration
  def self.up
    add_column :sources, :upload_token, :string
  end

  def self.down
    remove_column :sources, :upload_token
  end
end
