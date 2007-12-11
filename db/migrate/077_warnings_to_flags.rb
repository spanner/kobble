class WarningsToFlags < ActiveRecord::Migration
  def self.up
    rename_column :offenders_warnings, :warning_id, :flag_id
    rename_column :offenders_warnings, :offender_type, :flagging_type
    rename_column :offenders_warnings, :offender_id, :flagging_id
    rename_table :flaggings_flags, :offenders_warnings
    rename_table :flags, :warnings
    add_column :flags, :severity, :integer
  end

  def self.down
    rename_column :flaggings_flags, :flag_id, :warning_id
    rename_column :flaggings_flags, :flagging_type, :offender_type
    rename_column :flaggings_flags, :flagging_id, :offender_id
    rename_table :offenders_warnings, :flaggings_flags
    remove_column :flags, :severity
    rename_table :warnings, :flags
  end
end
