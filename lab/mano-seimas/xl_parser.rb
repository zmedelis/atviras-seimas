require 'rubygems'
require 'rexml/document'
require 'db'
include REXML

class XlParser
  attr_accessor :doc

  def initialize(root)
    @db =  DB.new
    @doc = Document.new root
    @doc << XMLDecl.new
  end

  def setup_data_block(worksheet_no, element_name)
    @worksheet = @workbook.worksheet(worksheet_no)
    @current_el = @item.add_element element_name
  end

  def add_element(name, text, attributes = nil)
    new_el = Element.new(name)
    new_el.text = text if text
    el = @current_el.add_element new_el
    if attributes then
      attributes.each{|x,y|
        el.attributes[x] = y.to_s
      }
    end
    el
  end
  
  def add_cdata_element(name, text, attributes = nil)
    new_el = Element.new(name)
    new_el.text = CData.new(text) if text
    el = @current_el.add_element new_el  
    if attributes then
      attributes.each{|x,y|
        el.attributes[x] = y.to_s
      }
    end    
  end

  def to_s(val)
    val ? val.to_s('utf-8').gsub('.0','') : ''
  end
  
  def row_s(row, col)
    row and row[col] ? row[col].to_s('utf-8') : ''
  end
  
  def row_i(row, col)
    row[col] and row[col].to_i != 0? row[col].to_i : ''
  end  
  def row_d(row, col)
    row[col] ? row[col].date : ''
  end
  def cell_s(row,col)
    to_s cell(row,col)
  end
  def cell_d(row,col)
    cell(row,col) ? cell(row,col).date : ""
  end

  def cell(r, c)
    @worksheet.row(r)[c]
  end
  
  def valid(row, check, size)
    row and (check == -1 ? true : row_s(row,check).size > 0) and row.size >= size
  end
  
  def fix_html(txt)
    if txt.include?('<p>') then
      t =  txt.gsub('<p>','').gsub('</p>', '<br/>')
      return t =~ /<br\/>$/ ? t[0..t.size-6] : t
    else
      return txt
    end
   end  
  
end
