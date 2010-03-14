class AddPilietinesDemokratijosFrakcija < ActiveRecord::Migration
  def self.up
    pg = PoliticalGroup.new
    pg.name = "Pilietinės demokratijos frakcija"
    pg.code = "PDF"  
    pg.save    
  end

  def self.down
  end
end
