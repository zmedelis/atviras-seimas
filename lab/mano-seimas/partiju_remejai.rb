#!/usr/bin/env ruby
require 'rubygems'
require 'parseexcel'
require 'xl_parser'


class Parser < XlParser

  def initialize
    super '<lrs/>'
    @db = DB.new
  end

  def parse(file)
    @workbook = Spreadsheet::ParseExcel.parse(file)
    @item = @doc.root.add_element 'partija'
    @item.attributes['id'] = @db.party_by_short_name(File.basename(file).split('.')[0]).to_s
    @current_el = @item
    @worksheet = @workbook.worksheet 1

    @worksheet.each(1){ |row|
      add_element 'remejas', nil, {
        'pavadinimas' => row[0].to_s('utf-8'),
        'tipas' => row[1].to_s('utf-8'),
        'suma' => row[2].to_f,
        'laikotarpis' => row_s(row, 3),
        'data' => row[4].date
      } if valid(row, 0, 5)
    }
    
    @worksheet = @workbook.worksheet 2
    @worksheet.each(1){ |row|
      add_element 'remejas', nil, {
        'pavadinimas' => row[0].to_s('utf-8'),
        'tipas' => row[1].to_s('utf-8'),
        'data' => row[2].date,
        'laikotarpis' => row[3].to_i,  
        'suma' => row[4].to_f
      } if valid(row, 0, 5)
    }

  end
end

p = Parser.new
Dir.foreach('partiju_remejai'){|xl|
  
  if xl.include? '.xls' then
    printf "#{xl}\n"
    p.parse 'partiju_remejai/' + xl
  end
  
}
p.doc.write( File.new('out/partiju_remejai.xml', 'w'), 0 )