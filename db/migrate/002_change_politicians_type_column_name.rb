class ChangePoliticiansTypeColumnName < ActiveRecord::Migration
  def self.up
    rename_column :positions, :type, :department
  end

  def self.down
    rename_column :positions, :department, :type
  end
end
