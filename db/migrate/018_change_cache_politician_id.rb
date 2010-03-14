class ChangeCachePoliticianId < ActiveRecord::Migration
  def self.up
    rename_column :mp_caches, :mp_id, :politician_id
  end

  def self.down
    rename_column :mp_caches, :politician_id, :mp_id
  end
end
