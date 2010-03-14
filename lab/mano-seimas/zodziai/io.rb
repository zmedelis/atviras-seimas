require 'rexml/document'
require 'iconv'
include REXML

=begin
  Ivairus teksto ekstaktinimo budai
=end

module Zeitgeist
    #duomenu skaitymas/rasymas
    module IO
    
      class OneFileLinesExtractor
          def extract(file, rule)
              lines = Array.new
              File.open(file).each_line{|line|
                lines << line.chomp if line[rule]
              }
              return lines
          end   
      end    
    
        class FileLinesExtractor
            def extract(dir, rule)
                lines = Array.new
                Dir[dir].each{|file|
                    File.open(file).each_line{|line|
                        lines << line.chomp if line[rule]
                    }
                }
                return lines
            end   
        end
        
        class HtmlTitleExtractor
            def extract( dir )
                titles = Array.new    
                Dir[dir].each{|file|
                    html = File.open(file).read
                    titles << html[html.index('<title>')+7..html.index('</title>')-1] 
                }
                return titles
            end
        end 
        
        class XmlExtractor
            def extract(dir, path)
                texts = Array.new
                Dir[dir].each do |file|
                    source = Document.new( File.new(file) )
                    XPath.each(source, path){|text| texts << text.to_s}
                end
                return texts
            end                
        end
        
        class ConsoleOutput
            def print( word_counter )
                word_counter.trims.each{|trim|
                    popular = word_counter.most_popular( trim )
                    puts trim + 
                        " visi: " + 
                        word_counter.sum( trim ).to_s + 
                        " pop: " + popular[0] + 
                        "-" + popular[1].to_s
                }
            end
        end
        
        class FileOutput
            def initialize( file )
                @file = File.new( file , 'w')
            end
            def print(word_counter)
                word_counter.trims.each{|trim|
                    popular = word_counter.most_popular( trim )
                    @file << trim + ", " + 
                    word_counter.sum( trim ).to_s + ", " + 
                    popular[0] + ", " + popular[1].to_s << "\n"
            }
            end
        end
        
        class HtmlLeveledOutput
            def initialize( file, encoder = nil )
                @encoder = encoder
                @FONT_SIZE = 10
                @FONT_INC = 4
                @file = File.new( file , 'w')
                @file << "<html><meta http-equiv='content-type content='text/html; charset=UTF-8'/><style  TYPE='text/css'>\n"
            end
            
            def print(word_counter)
                print_css( word_counter.levels )
                word_counter.trims.each do |trim|
                    popular = word_counter.most_popular( trim )
                    word = @encoder.nil? ? popular[0] : @encoder.iconv(popular[0])
                    @file << '<span class="lygis' + 
                        word_counter.trim_level(trim).to_s + 
                        '">' + word   + "</span>\n" 
                end
                @file << "</html>"
            end
            
            def print_css( levels )
                for i in 0..levels
                    @file << "span.lygis" + i.to_s + "{font-size:" + (@FONT_SIZE + i*@FONT_INC).to_s + "px}\n"
                end
                @file << "</style>"
            end
        end

        class DivLeveledOutput
            def initialize( file, encoder = nil )
                @encoder = encoder
                @FONT_SIZE = 10
                @FONT_INC = 2
                @file = File.new( file , 'w')
            end
            
            def print(word_counter)
                print_css( word_counter.levels )
                word_counter.trims.each do |trim|
                    popular = word_counter.most_popular( trim )
                    word = @encoder.nil? ? popular[0] : @encoder.iconv(popular[0])
                    @file << '<span class="lygis' + 
                        word_counter.trim_level(trim).to_s + 
                        '">' + word   + "</span>\n" 
                end
            end
            
            def print_css( levels )
		@file << "<style  TYPE='text/css'>\n"	 
               for i in 0..levels
                    @file << "span.lygis#{i} {font-size: #{@FONT_SIZE + i*@FONT_INC}px;\n}\n"
                end
                @file << "</style>\n"
            end
        end

    end
end
