class RenamePartyColumn < ActiveRecord::Migration
  def self.up
    rename_column :votes, :party_id, :political_group_id
  end

  def self.down
    rename_column :votes, :political_group_id, :party_id
  end
end
