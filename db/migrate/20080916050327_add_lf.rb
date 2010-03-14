class AddLf < ActiveRecord::Migration
  def self.up
    pg = PoliticalGroup.new
    pg.name = "Liberalų frakcija"
    pg.code = "LF"  
    pg.save  
  end

  def self.down
  end
end
