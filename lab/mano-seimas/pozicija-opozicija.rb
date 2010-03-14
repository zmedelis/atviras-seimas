#!/usr/bin/env ruby
require 'rubygems'
require 'parseexcel'
require 'xl_parser'

class Parser < XlParser

  def initialize
    super '<lrs/>'
  end
  
  def parse(file)
    @workbook = Spreadsheet::ParseExcel.parse(file) 
    
    @worksheet = @workbook.worksheet 1

    @worksheet.each(1) do |row|
      if row then
        @item = @doc.root.add_element 'frakcija'
        @item.attributes['id'] = row[0].to_i.to_s
        @item.attributes['pozicija'] = row[2].to_s('utf-8') == 'Pozicija' ? 'taip' : 'ne'
        @item.attributes['pradzia'] = row[4].date.to_s
        @item.attributes['pabaiga'] = row[5].date.to_s
      end
    end
  end
end

src = 'pozicija-opozicija/'
pi = Parser.new
Dir.foreach(src){|xl|
  if xl.include? '.xls' then
    printf "sXL: #{xl}\n"
    pi.parse src + xl
  end
}

pi.doc.write( File.new('out/pozicija-opozicija.xml', 'w') )