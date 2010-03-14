#!/usr/bin/env ruby
require 'rubygems'
require 'parseexcel'
require 'rexml/document'
require 'xl_parser'
require 'activerecord'


include REXML
ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :database => 'seimas_development',
  :encoding => 'utf8',
  :username => 'root',
  :password => '',
  :host     => 'localhost')

class Politician < ActiveRecord::Base
end

class ParserInfo < XlParser

  def initialize
    super '<lrs/>'
  end
  
  def parse(file)
    @workbook = Spreadsheet::ParseExcel.parse(file) 
    @item = @doc.root.add_element 'projektas'
    @worksheet = @workbook.worksheet 1
    @current_el =  @item

    @item.attributes['id'] = cell_s(0,1).strip
    add_cdata_element 'pavadinimas', cell_s(1,1), {'trumpas' => cell_s(2,1)}
    @item.attributes['temos_id'] = @db.theme_id(cell_s(5,1)).to_s
    @item.attributes['pateiktas'] = @worksheet.row(11)[1].date.to_s
    @item.attributes['sprendimas'] = @worksheet.row(12)[1].date.to_s
    b = @worksheet.row(13)[1].to_s('utf-8')
    bus = 'svarstoma' if b =='Svarstomas' 
    bus = 'priimta' if b =='Priimtas' 
    bus = 'atmesta' if b =='Atmestas' 
    @item.attributes['busena'] = bus


    @current_el = @current_el.add_element 'pateike'
    name = cell_s(6,1).split
    p = Politician.find_by_last_name_and_first_name(name.first, name.last)
    add_element 'seimo_narys', nil, {'id'=>p.id_in_lrs} if p
    add_element 'kita', nil, {'vardas'=>cell_s(6,1)} unless p
    
    @current_el = @item
    
    add_cdata_element 'aprasymas', cell_s(8,1), {}
  end

end

class ParserVotes < XlParser

  def initialize
    super '<lrs/>'
  end
  
  def parse(file)
    @workbook = Spreadsheet::ParseExcel.parse(file) 
    @item = @doc.root.add_element 'balsavimas'
    @worksheet = @workbook.worksheet 1
    @current_el =  @item

    @item.attributes['projekto_id'] = cell_s(0,1)
    
    @worksheet = @workbook.worksheet 3
    @worksheet.each(1)do |row|
      name = row[0].to_s('utf-8').split
      
      yes = row[2].to_i
      no = row[3].to_i
      abstain = row[4].to_i
      register = row[5].to_i
      
      novote = register - (yes + no + abstain) 
      absent = 1 - register
      
      action = 'taip' if yes == 1
      action = 'ne' if no == 1
      action = 'susilaike' if abstain == 1
      action = 'nebalsavo' if novote == 1
      action = 'nedalyvavo' if absent == 1
      
      txt = row[8].to_s('utf-8') if row[8]
      puts row[0].to_s('utf-8')
      add_cdata_element( 'balsas', txt,{
        'seimo_nario_id'=>Politician.find_by_last_name_and_first_name(name.first, name.last).id_in_lrs,
        'veiksmas'=>action
        }
      ) if row
    end
   end
end


src = 'balsavimai/'
pi = ParserInfo.new
Dir.foreach(src){|xl|
  if xl.include? '.xls' then
    pi.parse src + xl
  end
}

pi.doc.write( File.new('out/projektai.xml', 'w') )

src = 'balsavimai/'
pv = ParserVotes.new
Dir.foreach(src){|xl|
  if xl.include? '.xls' then
    printf "*** #{xl}\n"
    pv.parse src + xl
  end
}
pv.doc.write( File.new('out/balsavimai.xml', 'w') )
