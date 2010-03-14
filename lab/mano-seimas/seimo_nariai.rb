#!/usr/bin/env ruby
require 'rubygems'
require 'parseexcel'
require 'xl_parser'
require 'activerecord'

ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :database => 'seimas_development',
  :encoding => 'utf8',
  :username => 'okam',
  :password => 'no',
  :host     => 'localhost')

class Politician < ActiveRecord::Base
  has_many :vote_patterns, :order => 'score'
  has_many :positions
end
class VotePattern < ActiveRecord::Base
  belongs_to :politician
  belongs_to :similar_voter, :class_name => 'Politician', :foreign_key => 'similar_voter_id'
end

class Position < ActiveRecord::Base
  belongs_to :politician
end

class Parser < XlParser

  def initialize
    super '<politikai/>'
  end
  
  def parse(file)
    @workbook = Spreadsheet::ParseExcel.parse(file) 
    @item = @doc.root.add_element 'politikas' 
    
    person
    #residence
    education
    job
    party
    #politics
    politics_parliament
    politics_government
    politics_local_government
    commisions
    income
    candidate_support
    similarity
  end
  private  
  
  def person
    setup_data_block 1, 'asmuo'
    @mp = Politician.find_by_id_in_lrs cell_s(0,1)
    @item.attributes['id'] = cell_s(0,1)
    @item.attributes['nuoroda_kandidatas'] = cell_s(1,1)
    @item.attributes['kede'] = cell_s(2,1)
    
    printf "vardas: #{@mp.last_name}\n"
    
    add_element 'apygarda', @mp.constituency == '' ? 'Daugiamandatė' : @mp.constituency
    
    add_element 'kadencija', nil, {
        'visos'         => cell_s(3,1),
        'dabartine'     => cell_s(4,1),
        'dabar_pradzia' => cell_d(5,1),
        'dabar_pabaiga' => cell_d(6,1)
    }
    
    add_element 'vardas', nil, {
      'pirmas'  => cell_s(7,1),
      'antras'  => cell_s(8,1),
      'pavarde' => cell_s(9,1),
    }

    add_element 'gime', nil, {
      'data_tiksli'  => cell_d(10,1),
      'data_grupuota'  => cell_s(11,1),
      'vieta_tiksli' => cell_s(13,1),
      'vieta_grupuota' => cell_s(14,1),
    }
    
    add_element 'lytis', cell_s(12,1)
    
    add_element 'gyvenamoji_vieta', nil, {
      'tiksli'  => cell_s(15,1),
      'grupuota'  => cell_s(16,1)
    }
    
    add_element 'tautybe', cell_s(17,1)
    add_element 'seimynine_padetis', cell_s(18,1)  
    add_cdata_element 'seimo_posedziuose', cell_s(19,1)
    add_cdata_element 'kita_info', cell_s(20,1)
  end
=begin  
  def residence
    setup_data_block 2, 'gyvenamoji_vieta'
    @worksheet.each(1){ |row|
      printf "gyvena: #{row_s(row, 2)}\n"  if valid(row,2,3)
      add_element 'vieta', nil, {
        'data' => row[0].date.to_s,
        'vietove' => row[2].to_s('utf-8')#,
        #'vietove_soc' => row[2].to_s('utf-8')
      } if valid(row,2,3)
    } 
  end
=end  
  def education
    setup_data_block 2, 'issimokslinimas'
    @worksheet.each(1){ |row|
      add_element( 'studijos', nil, {
          'istaiga_ir_specialybe'  => row_s(row,0),
          'universitetas'  => row_s(row,1),
          'pradzia' => row_s(row, 2),
          'pabaiga' => row_s(row, 3),
          'metai' => row_s(row,4),
          'sritis' => row_s(row,5)
        })if valid(row,0,6)
    }    
  end
  
  def job
    setup_data_block 3, 'darbine_veikla'
    @worksheet.each(1){ |row|
      add_element 'darbas', nil,{
        'darboviete_ir_pareigos' => row_s(row,0),
        'pradzia' => row_i(row,1),
        'pabaiga' => row_i(row,2),
        'laikotarpis' => row_s(row,3),
        'saka' => row_s(row,5)
      }if valid(row,0,5)
    }
  end
  
  def party
    setup_data_block 4, 'visuomenine_partine_veikla'
    @worksheet.each(1){ |row|
      add_element 'veikla', nil,{
        'tipas' => row_s(row, 0),
        'pavadinimas_ir_pareigos' => row_s(row, 1),
        'pavadinimas_trumpas' => row_s(row, 2),
        'pradzia' => row_i(row,3),
        'pabaiga' => row_i(row,4),
        'laikotarpis' => row_s(row,5)
      } if valid(row,0,6)
    }
  end
  
  #def politics
  #  setup_data_block 6, 'politine_veikla'
  #  add_element 'disidentas', cell_s(0,1)
  #  add_element 'nomenklaturos_atstovas', cell_s(1,1)
  #  add_element 'sajudzio_iniciatyvines_grupes_narys', cell_s(2,1)
  #  add_element 'kovo_11_signataras', cell_s(3,1)
  #  add_element 'kadencijos', cell_s(4,1)
  #end
  
  def politics_parliament
    setup_data_block 5, 'politine_veikla_seime'
    @worksheet.each(1) do |row|
      if valid(row,0, 6) then
        instit = row[0].to_s('utf-8')
        name = row_s(row,2)
        id = -1
        id = @db.political_group_by_name(name) if instit == 'Frakcija'
        id = @db.committee_by_name(name) if instit == 'Komitetas'
      	add_element 'veikla', nil,{
      	  'id' => id,
          'institucija' => instit,
          'kadencija' => row_s(row, 1),
          'pavadinimas' => name,
          'pradzia' => row_d(row,3),
          'pabaiga' => row_d(row,4),
          'pareigos' => row_s(row,5)
      	}
      end
    end
    @mp.positions.find(:all, :conditions => ["department = 'frakcija' or department = 'komitetas'"]).each do |job|
      id = -1
      desc = job.description.gsub('"', "'")
      id = @db.political_group_by_name(desc) if job.department == 'frakcija'
      id = @db.committee_by_name(job.description) if job.department == 'komitetas'
      par = job.title
      par = 'Narys,-ė' if job.title.include? 'narys' or job.title.include? 'narė'
      add_element 'veikla', nil,{
        'id' => id,
        'institucija' => job.department.capitalize,
        'kadencija' => '2008-2012',
        'pavadinimas' => desc,
        'pradzia' => job.from.to_s,
        'pabaiga' => job.to.to_s,
        'pareigos' => par
      }
    end
  end
  
  def politics_government
    setup_data_block 7, 'politine_veikla_vyriausybeje'
    @worksheet.each(1){ |row|
      add_element 'veikla', nil,{
        'ministerija' => row_s(row,0),
        'pradzia' => row_d(row,1),
        'pabaiga' => row_d(row,2),
        'laikotarpis' => row_s(row,3),
        'pareigos' => row_s(row,4),
      }  if valid(row,0,5) 
    }
  end
  
  def politics_local_government
    setup_data_block 8, 'politine_veikla_savivaldybeje'
    @worksheet.each(1){ |row|
      add_element 'veikla', nil,{
        'pavadinimas_ir_pareigos' => row_s(row,0),
        'pradzia' => row_d(row,1),
        'pabaiga' => row_d(row,2),
        'laikotarpis' => row_s(row,3)
      } if valid(row,0,4)
    }
  end

  def commisions
    setup_data_block 6, 'priklausomybe_laikinosioms_komisijoms'
    @worksheet.each(1){ |row|
      add_element 'komisija', nil,{
        'pavadinimas_ir_pareigos' => row_s(row,0),
        'pradzia' => row_d(row,1),
        'pabaiga' => row_d(row,2)
      } if valid(row, 0, 3)
    }
  end
  
  def income
    setup_data_block 9, 'turtas_pajamos'
    @worksheet.each(1){ |row|
      add_element 'turtas', nil,{
        'data' => row_d(row,0),
        'sn_turtas_suma' => row_i(row,1),
        'sn_turtas_sarasas' => row_s(row,2),
        'sutuoktinio_turtas_suma' => row_i(row,3),
        'sutuoktinio_turtas_sarasas' => row_s(row,4),
        'sn_ir_sutuoktinio_turtas_suma' => row_i(row,5),
        'sn_ir_sutuoktinio_turtas_sarasas' => row_s(row,6),
        'sn_pajamos_suma' => row_i(row,7),
        'sn_pajamos_sarasas' => row_s(row,8)
      } if valid(row, 0, 9)
    }
  end

  def candidate_support
    setup_data_block 10, 'remia'
    @worksheet.each(1){ |row|
      add_element 'remejas', nil, {
        'pavadinimas' => row_s(row,0),
        'tipas' => row_s(row,1),
        'suma' => row_i(row,2),
        'data' => row_d(row,3)
      } if valid(row, 0, 4)
    }       
    
  end
  
  def similarity
    @current_el = @item.add_element 'balsavimo_panasumas'
    @mp.vote_patterns.each{ |sim|
      add_element 'seimo_narys', nil,{
        'id' => Politician.find(sim.similar_voter_id).id_in_lrs,
        'panasumas' => sim.score
      }
    }
  end
end

sn_dir = 'seimo_nariai'
p = Parser.new
Dir.foreach(sn_dir){|xl|
  if xl.include? '.xls' then
    printf "#{xl}\n"
    p.parse "#{sn_dir}/" + xl
  end
}
p.doc.write( File.new('out/seimo_nariai.xml', 'w'), 1 )
