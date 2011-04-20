class RenameCalledBackBy < ActiveRecord::Migration
  def self.up
    rename_column :trips, :called_back_by, :called_back_by_id
  end

  def self.down
    rename_column :trips, :called_back_by_id, :called_back_by
  end
end
