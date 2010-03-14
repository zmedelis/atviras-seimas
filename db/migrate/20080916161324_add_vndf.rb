class AddVndf < ActiveRecord::Migration
  def self.up
    pg = PoliticalGroup.new
    pg.name = "Valstiečių ir Naujosios demokratijos frakcija"
    pg.code = "VNDF"  
    pg.save
  end

  def self.down
  end
end
