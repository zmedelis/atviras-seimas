class ChangePoliticalGroupIdType < ActiveRecord::Migration
	def self.up
		change_column :votes, :political_group_id, :int
	end

	def self.down
		change_column :votes, :political_group_id, :string
	end
end
