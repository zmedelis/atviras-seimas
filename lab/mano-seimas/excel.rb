#!/usr/bin/env ruby
require 'rubygems'
require 'parseexcel'
require 'rexml/document'
require 'db'

include REXML

class Parser

  attr_accessor :doc

  def initialize
		@db =  DB.new
    @doc = Document.new '<politikai/>'
    @doc << XMLDecl.new
    
  end
  
  def parse(file)
    @workbook = Spreadsheet::ParseExcel.parse(file) 
    @politician = @doc.root.add_element 'politikas' 
    
    person
    residence
    education
    job
    party
    politics
    politics_parliament
    politics_government
    politics_local_government
    commisions
    income
    similarity
  end
private  
  
  def person
    setup_data_block 1, 'asmuo'
    @politician.attributes['id'] = cell_s(0,1)
    add_element 'kadencija', cell_s(1,1)
    add_element 'vardas', cell_s(2,1)
    add_element 'antras_vardas', cell_s(3,1)
    add_element 'pavarde', cell_s(4,1)
    add_element 'gimimo_data', cell_d(5,1)
    add_element 'lytis', cell_s(7,1)
    add_element 'gimimo_vieta_irasyta', cell_s(8,1)
    add_element 'gimimo_vieta_sarase', cell_s(9,1)
    add_element 'tautybe', cell_s(10,1)
    add_element 'seimynine_padetis', cell_s(12,1)
    add_element 'vaikai', cell_s(13,1)
    add_element 'tevo_uzsiemimas_irasyta', cell_s(14,1)
    add_element 'tevo_uzsiemimas_sarase', cell_s(15,1)
    add_element 'motinos_uzsiemimas_irasyta', cell_s(16,1)
    add_element 'motinos_uzsiemimas_sarase', cell_s(17,1)
    add_element 'teistumo_istorija', cell_s(18,1)  
  end
  
  def residence
    setup_data_block 2, 'gyvenamoji_vieta'
    @worksheet.each(1){ |row|
      add_element 'vieta', nil, {
        'data' => row[0].date.to_s,
        'vietove' => row[2].to_s('utf-8')
      } if row and row[0] and row[2].to_s('utf-8').size > 0
    } 
  end
  
  def education
    setup_data_block 3, 'issimokslinimas'
    @worksheet.each(1){ |row|
      add_element( 'studijos', nil, {
        'lygmuo_irasyta'  => row[0].to_s('utf-8'),
        'lygmuo_sarase'  => row[1].to_s('utf-8'),
        'istaiga_irasyta' => row[2].to_s('utf-8'),
        'istaiga_sarase' => row[3].to_s('utf-8'),
        'pradzia' => row[4] ? row[4].to_i : '',
        'pabaiga' => row[5].to_i,
        'sritis_irasyta' => row[6].to_s('utf-8'),
        'sritis_sarase' => row[7].to_s('utf-8')
      }) if row and row[0] and row.size == 8
    }    
  end
  
  def job
    setup_data_block 4, 'darbine_veikla'
    @worksheet.each(1){ |row|
      add_element 'darbas', nil,{
        'darboviete' => row[0].to_s('utf-8'),
        'pradzia' => row[1].to_i,
        'pabaiga' => row[2].to_i,
        'sektorius' => row[3].to_s('utf-8'),
        'saka' => row[4].to_s('utf-8'),
        'veikla' => row[5].to_s('utf-8'),
        'pareigos' => row[6].to_s('utf-8'),
        'pobudis' => row[7].to_s('utf-8')
      } if row and row[0] and row.size == 8
    }
  end
  
  def party
    setup_data_block 5, 'visuomenine_partine_veikla'
    @worksheet.each(1){ |row|
      add_element 'darbas', nil,{
        'tipas' => row[0].to_s('utf-8'),
        'pavadinimas_irasyta' => row[1].to_s('utf-8'),
        'pavadinimas_sarase' => row[2] ? row[2].to_s('utf-8'):'',
				'id' => row[2] ? @db.party_by_short_name(row[2].to_s('utf-8')) : '-1',
        'pradzia' => row[3].to_i,
        'pabaiga' => row[4].to_i,
        'pareigos_irasyta' => row[5].to_s('utf-8'),
        'pareigos_sarase' => row[6].to_s('utf-8'),
        'pareigos_dabar_irasyta' => row[7].to_s('utf-8'),
        'pareigos_dabar_sarase' => row[8].to_s('utf-8')
      } if row and row.size == 9
    }
  end
  
  def politics
    setup_data_block 6, 'politine_veikla'
    add_element 'disidentas', cell_s(0,1)
    add_element 'nomenklaturos_atstovas', cell_s(1,1)
    add_element 'sajudzio_iniciatyvines_grupes_narys', cell_s(2,1)
    add_element 'kovo_11_signataras', cell_s(3,1)
    add_element 'kadencijos', cell_s(4,1)
  end
  
  def politics_parliament
    setup_data_block 7, 'politine_veikla_seime'
    @worksheet.each(1){ |row|
			if row then
				instit = row[0].to_s('utf-8')
				name = row[1].to_s('utf-8')
				id = -1
				id = @db.political_group_by_name(name) if instit == 'Frakcija'
				id = @db.committee_by_name(name) if instit == 'Komitetas'
      	add_element 'veikla', nil,{
        	'institucija' => instit,
        	'pavadinimas' => name,
					'id' => id,
        	'pradzia' => row[2].date,
        	'pabaiga' => row[3].date,
        	'pareigos' => row[4].to_s('utf-8'),
      	}
			end
    }  
  end
  
  def politics_government
    setup_data_block 8, 'politine_veikla_vyriausybeje'
    @worksheet.each(1){ |row|
      add_element 'veikla', nil,{
        'ministerija' => row[0].to_s('utf-8'),
				'id' => @db.ministry_by_name(row[0].to_s('utf-8')),
        'pradzia' => row[1].date,
        'pabaiga' => row[2].date,
        'pareigos' => row[3].to_s('utf-8')
      }  if row and row.size == 4
    }  
  end
  
  def politics_local_government
    setup_data_block 9, 'politine_veikla_savivaldybeje'
    @worksheet.each(1){ |row|
      add_element 'veikla', nil,{
        'savivaldybe' => row[0].to_s('utf-8'),
        'pradzia' => row[1].date,
        'pabaiga' => row[2].date,
        'visos_pareigos' => row[3].to_s('utf-8'),
        'paskutines_pareigos' => row[4].to_s('utf-8')
      } if row and row.size == 5
    }  
  end

  def commisions
    setup_data_block 10, 'priklausomybe_laikinosioms_komisijoms'
    @worksheet.each(1){ |row|
      add_element 'veikla', nil,{
        'komisija' => row[0].to_s('utf-8'),
        'pradzia' => row[1].date,
        'pabaiga' => row[2].date,
        'pareigos' => row[3].to_s('utf-8')
      } if row[0] 
    }  
  end
  
  def income
    setup_data_block 11, 'turtas_pajamos'
    @worksheet.each(1){ |row|
      add_element 'turtas', nil,{
        'data' => row[0].date,
        'privalomas_registruoti_turtas' => row[1].to_i,
        'pinigines_lesos' => row[2].to_i,
        'suteiktos_paskolos' => row[3].to_i,
        'gautos_paskolos' => row[4].to_i,
        'sutuoktinio_privalomas_registruoti_turtas' => row[7].to_i,
        'sutuoktinio_pinigines_lesos' => row[8].to_i,
        'sutuoktinio_suteiktos_paskolos' => row[9].to_i,
        'sutuoktinio_gautos_paskolos' => row[10].to_i,
        'visos_asmenines_pajamos' => row[13].to_i
      } if row and row[0]#and row.size == 16
    }
  end  
  
  def similarity
    @current_el = @politician.add_element 'balsavimo_panasumas'
    add_element 'seimo_narys', nil,{
      'id' => 'ID1',
      'panasumas' => 0.87
    }
    add_element 'seimo_narys', nil,{
      'id' => 'ID2',
      'panasumas' => 0.26
    }
  end

  def setup_data_block(worksheet_no, element_name)
    @worksheet = @workbook.worksheet(worksheet_no)
    @current_el = @politician.add_element element_name  
  end

  def add_element(name, text, attributes = nil)
    el = @current_el.add_element name
    el.text = text if text
    if attributes then
      attributes.each{|x,y|
        el.attributes[x] = y.to_s
      }
    end
  end

  def to_s(val)
    val ? val.to_s('utf-8').gsub('.0','') : ''
  end

  def cell_s(row,col)
    to_s cell(row,col)
  end
  def cell_d(row,col)
    cell(row,col).date
  end

  def cell(r, c)
    @worksheet.row(r)[c]
  end

end


Dir.foreach('seimo_nariai'){|xl|
	if xl.include? '.xls' then
		p = Parser.new
		printf "XL: #{xl}\n"
		p.parse 'seimo_nariai/' + xl
		puts 'out/' + File.basename(xl, '.xls')
		p.doc.write( File.new('out/' + File.basename(xl, '.xls') + '.xml', 'w'), 1 )
	end
}
