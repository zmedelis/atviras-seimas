class ChangeMpToPoliticianId < ActiveRecord::Migration
  def self.up
    rename_column :trips, :mp_id, :politician_id
  end

  def self.down
    rename_column :trips, :politician_id, :mp_id
  end
end
