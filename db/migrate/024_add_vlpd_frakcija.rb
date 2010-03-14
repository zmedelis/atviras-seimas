class AddVlpdFrakcija < ActiveRecord::Migration
  def self.up
    pg = PoliticalGroup.new
    pg.name = "Valstiečių liaudininkų ir pilietinės demokratijos frakcija"
    pg.code = "VLPD"  
    pg.save
  end

  def self.down
  end
end
