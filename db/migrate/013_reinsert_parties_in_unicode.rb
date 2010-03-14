class ReinsertPartiesInUnicode < ActiveRecord::Migration
	def self.up
		drop_table :political_groups
		CreatePoliticalGroups.up
		AddPilietinesDemokratijosFrakcija.up
	end

	def self.down
		
	end
end
