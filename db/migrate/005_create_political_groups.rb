class CreatePoliticalGroups < ActiveRecord::Migration
  def self.up
    create_table :political_groups do |t|
      t.string :name
      t.string :code, :limit=>10
    end
    pg = PoliticalGroup.new
    pg.name = "Lietuvos socialdemokratų partijos frakcija"
    pg.code = "LSDPF"  
    pg.save
    pg = PoliticalGroup.new
    pg.name = "Tėvynės Sąjungos frakcija"
    pg.code = "TSF"  
    pg.save
    pg = PoliticalGroup.new
    pg.name = "Darbo partijos frakcija"
    pg.code = "DPF"  
    pg.save
    pg = PoliticalGroup.new
    pg.name = "Valstiečių liaudininkų frakcija"
    pg.code = "VLF"  
    pg.save
    pg = PoliticalGroup.new
    pg.name = "Frakcija \"Tvarka ir teisingumas\""
    pg.code = "TTF"  
    pg.save
    pg = PoliticalGroup.new
    pg.name = "Liberalų ir centro sąjungos frakcija"
    pg.code = "LCSF"  
    pg.save
    pg = PoliticalGroup.new
    pg.name = "Naujosios sąjungos (socialliberalų) frakcija"
    pg.code = "NSF"  
    pg.save
    pg = PoliticalGroup.new
    pg.name = "Liberalų sąjūdžio frakcija"
    pg.code = "LSF"  
    pg.save
    pg = PoliticalGroup.new
    pg.name = "Mišri Seimo narių grupė"
    pg.code = "MG"
    pg.save  
  end

  def self.down
    drop_table :political_groups
  end
end
