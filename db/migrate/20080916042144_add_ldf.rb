class AddLdf < ActiveRecord::Migration
  def self.up
    pg = PoliticalGroup.new
    pg.name = "Liberalų demokratų frakcija"
    pg.code = "LDF"  
    pg.save    
  end

  def self.down
  end
end
