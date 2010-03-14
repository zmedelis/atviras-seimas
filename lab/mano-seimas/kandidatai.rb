#!/usr/bin/env ruby
require 'rubygems'
require 'parseexcel'
require 'xl_parser'

class Parser < XlParser

  def initialize
    super '<politikai/>'
  end
  
  def parse(file)
    @workbook = Spreadsheet::ParseExcel.parse(file) 
    @item = @doc.root.add_element 'politikas' 
    @current_el = @item
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
    candidate_support
  end
  private
  
  def person
    setup_data_block 1, 'asmuo'
    puts cell_s(6,1) if cell_s(6,1).nil? or cell_s(6,1).size == 0
		@last_name = cell_s(6,1)
    @item.attributes['id'] = cell_s(0,1).gsub('Kandidatas','').gsub('Kandidato','')
    add_element 'apygarda', cell_s(1,1)
    @item.attributes['nuoroda'] = cell_s(2,1)
    add_element 'kadencija', cell_s(3,1)
    add_element 'vardas', cell_s(4,1)
    add_element 'antras_vardas', cell_s(5,1)
    add_element 'pavarde', cell_s(6,1)
    add_element 'gimimo_data', cell_d(7,1)
    #add_element 'gimimo_data_soc', cell_s(8,1)
    add_element 'lytis', cell_s(9,1)
    add_element 'gimimo_vieta_irasyta', cell_s(10,1)
    vietove = cell_s(11,1)
    vietove = "Ne Lietuva bet ne tremtis" if vietove == 'Ne Lietuva (bet ne tremtis)'
    vietove = "Miestelis arba kaimas" if vietove == 'Kita Lietuvos vietovė'    
    add_element 'gimimo_vieta_sarase', vietove
    add_element 'tautybe', cell_s(12,1)
    add_element 'seimynine_padetis', cell_s(14,1)
    add_element 'vaikai', cell_s(15,1)
    add_element 'tevo_uzsiemimas_irasyta', cell_s(16,1)
    add_element 'tevo_uzsiemimas_sarase', cell_s(17,1)
    add_element 'motinos_uzsiemimas_irasyta', cell_s(18,1)
    add_element 'motinos_uzsiemimas_sarase', cell_s(19,1)
    add_element 'teistumo_istorija', cell_s(20,1)  
    add_cdata_element 'ziniasklaidoje', fix_html(cell_s(21,1))
    add_cdata_element 'nuorodos', fix_html(cell_s(22,1))
    add_cdata_element 'nuostatos', fix_html(cell_s(23,1))
  end
  
  def residence
    setup_data_block 2, 'gyvenamoji_vieta'
    @worksheet.each(1){ |row|
      if valid(row, 2, 3)
        vietove = row[2].to_s('utf-8')
        vietove = "Ne Lietuva bet ne tremtis" if vietove == 'Ne Lietuva (bet ne tremtis)'
        vietove = "Miestelis arba kaimas" if vietove == 'Kita Lietuvos vietovė'
        add_element 'vieta', nil, {
          'data' => row[0].date.to_s,
          'vietove' => vietove#,
          #'vietove_soc' => row[2].to_s('utf-8')
        }
      end
    } 
  end
  
  def education
    setup_data_block 3, 'issimokslinimas'
    @worksheet.each(1){ |row|
      add_element( 'studijos', nil, {
          'lygmuo_irasyta'  => row_s(row,0),
          'lygmuo_sarase'  => row_s(row,1),
          'istaiga_irasyta' => row_s(row,2),
          'istaiga_sarase' => row_s(row,3),
          'istaiga_trumpas' => row_s(row,4),
          'pradzia' => row_i(row,5),
          'pabaiga' => row_i(row,6),
          'sritis_irasyta' => row_s(row,7) == 'Bendrasis' ? '' : row_s(row,7) ,
          'sritis_sarase' => row_s(row,8)
        }) if valid(row,2,9)
    }    
  end
  
  def job
    setup_data_block 4, 'darbine_veikla'
    @worksheet.each(1){ |row|
      puts row.size if row and row.size > 9
      add_element 'darbas', nil,{
        'darboviete' => row[0].to_s('utf-8'),
        'pradzia' => row[1].to_i,
        'pabaiga' => row[2].to_i,
        'sektorius' => row_s(row,3),
        'saka' => row_s(row,5),
        #'saka_soc' => row_s(row,5),
        'veikla' => row_s(row,6),
        'pareigos' => row_s(row,7),
        'pobudis' => row_s(row,8)
      } if valid(row,0,9) or valid(row,0,7) or valid(row,0,8)
    }
  end
  
  def party
    setup_data_block 5, 'visuomenine_partine_veikla'
		nr_sarase = false 
    @worksheet.each(1){ |row|
      e=add_element 'darbas', nil,{
        'tipas' => row_s(row,0),
        'pavadinimas_irasyta' => row_s(row,1),
        'pavadinimas_sarase' => row_s(row,2),
        'pradzia' => row_i(row,3),
        'pabaiga' => row_i(row,4),
        'pareigos_irasyta' => row_s(row,5),
        'pareigos_sarase' => row_s(row,8)
      } if row and row.size[0].size > 0 and row.size >= 8
			if e and row.size[0].size > 0 and row.size == 10 and row[9] then
				nr = row[9].to_i
				if nr > 0 then
      		e.attributes['nr_sarase'] = nr.to_s 
					printf "nr_sarase #{e.attributes['nr_sarase']}\n" 
				else
					e.attributes['nr_sarase'] = ''
				end
			else
				if e then
					 e.attributes['nr_sarase'] = ''
				end
			end
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
    @worksheet.each(1) do |row|
      if row and row[0] and row[0].to_s('utf-8').size > 0 and row.size == 5 then
        instit = row[0].to_s('utf-8')
        name = row_s(row,1)
        id = -1
        id = @db.political_group_by_name(name) if instit == 'Frakcija'
        id = @db.committee_by_name(name) if instit == 'Komitetas'
      	add_element 'veikla', nil,{
          'institucija' => instit,
          'pavadinimas' => name,
          'id' => id,
          'pradzia' => row_d(row,2),
          'pabaiga' => row_d(row,3),
          'pareigos' => row[4].to_s('utf-8'),
      	}
      end
    end
  end
  
  def politics_government
    setup_data_block 8, 'politine_veikla_vyriausybeje'
    @worksheet.each(1){ |row|
      add_element 'veikla', nil,{
        'ministerija' => row[0].to_s('utf-8'),
        'id' => @db.ministry_by_name(row[0].to_s('utf-8')),
        'pradzia' => row_d(row,1),
        'pabaiga' => row_d(row,2),
        'pareigos' => row_s(row,3) 
      }  if valid(row, 0, 4) or valid(row, 0, 3) 
    }
  end
  
  def politics_local_government
    setup_data_block 9, 'politine_veikla_savivaldybeje'
    @worksheet.each(1){ |row|
      add_element 'veikla', nil,{
        'savivaldybe' => row_s(row,0),
        'pradzia' => row[1].date.to_s,
        'pabaiga' => row[2] ? row[2].date : "",
        'visos_pareigos' => row_s(row,3),
        'paskutines_pareigos' => row_s(row,4)
      } if valid(row, 0, 5)
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
      }if valid(row, 0, 4)
    }
  end
  
  def income
    setup_data_block 11, 'turtas_pajamos'
    @worksheet.each(1){ |row|
      add_element 'turtas', nil,{
        'data' => row_d(row,0),
        'privalomas_registruoti_turtas' => row[1].to_i,
        'pinigines_lesos' => row[2].to_i,
        'suteiktos_paskolos' => row[3].to_i,
        'gautos_paskolos' => row[4].to_i,
        'sutuoktinio_privalomas_registruoti_turtas' => row[7].to_i,
        'sutuoktinio_pinigines_lesos' => row[8].to_i,
        'sutuoktinio_suteiktos_paskolos' => row[9].to_i,
        'sutuoktinio_gautos_paskolos' => row[10].to_i,
        'visos_asmenines_pajamos' => row[13].to_i
      } if valid(row, -1, 15) #and not row[0].date.nil?
    }
  end

  def candidate_support
    setup_data_block 12, 'remia'
    @worksheet.each(1){ |row|
      add_element 'remejas', nil, {
        'pavadinimas' => row_s(row,0),
        'tipas' => row_s(row,1),
        'suma' => row_i(row,2),
        'data' => row_d(row,3),
        'laikotarpis' => row_s(row,4)
      } if valid(row, 0, 5) or row_s(row,0) == '###'
    }       
  end
  
end

p = Parser.new
Dir.foreach('kandidatai'){|xl|
  if xl.include? '.xls' then
    puts 'kandidatai/' + xl
    p.parse 'kandidatai/' + xl
  end
}
p.doc.write( File.new('out/kandidatai.xml', 'w') )
