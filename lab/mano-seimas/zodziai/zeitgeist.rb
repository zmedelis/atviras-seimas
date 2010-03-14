=begin

WordCounter - zodziu skaiciavimas ir paskirstymas pagal lygius.
TextAnalyzer - teksto analize, zodziu kamienu paieska

=end

module Zeitgeist

    # sitas daiktas skaiciuoja zodzius, paskirsto pagal lygius
    # ir papildomai dar duoda pati populiariausia zodi is 
    # visu trumpini 9zr most_popular_trim
    # 
    # trim cia reiskia zodzio sakni:
    #     kiemas, kiemai, kiemuose --> trim = kiem
    #
    class WordCounter
        attr_reader :levels
        attr_accessor :min_ignore_size
        
        # levels - i kiek lygiu suskirstit 
        # ignore_size - kiek min zodziu turi poasikartoti kad patektu i skaiciavima
        def initialize( levels, ignore_size = 0 )
            @trims = Hash.new
            @levels = levels
            @min_ignore_size = ignore_size
        end
        
        def add(word, trimmed_word)
            @trims[trimmed_word] = Hash.new if @trims[trimmed_word].nil?
            @trims[trimmed_word][word] = @trims[trimmed_word][word].nil? ? 
                1 : @trims[trimmed_word][word] + 1 
        end
        
        def most_popular( trim )
            max = @trims[trim].values.max   #TODO cia biski kreiva paieska
            return @trims[trim].find{|x,y| y == max}
        end
        
        def trims
            @trims.keys.reject{ |x| sum(x) <= @min_ignore_size }
        end
        
        def sum( trim )
            sum = 0
            @trims[trim].values.each{|x|sum += x}
            sum
        end
        
        def words( trim )
            @trims[trim].keys
        end
        
        def most_popular_trim_sum
            sum(trims.max{|a,b| sum( a ) <=> sum( b )})
        end
        
        def least_popular_trim_sum
            sum(trims.min{|a,b| sum( a ) <=> sum( b )})
        end
        
        def trim_level( trim )
            max = most_popular_trim_sum
            min = least_popular_trim_sum
            ( 1.0*sum(trim)*@levels / (max - min) ).round - 1
            ( 1.0*(sum(trim) - min)*@levels / (max - min) ).round
        end
    end
    
    # cia teksto analizavimas, skanuojamas tekstas  
    # skaldom i atskirus zodzius ir jei zodis nera tarp
    # ignoruojamu saraso imam ji analizuoti. kamieno
    # atradimas labai primitivus gavus zodi nutrinamos
    # paskutines N raidziu, tam kad spresti ilgu/trumpu zodziu skirtumus
    # trinimui yra dvi taisykles jei zodis yra iki A ilgo tai jis visas
    # analizuojamas, jei ilgis nuo A+1 iki B tai atimamos 2 raides
    # jei daugiau (B+1) tai 3
    class TextAnalyser
        attr_writer :ignore_database, :word_combinations_database
        
        # first_range tai jei ilgis nuo A iki B tai atimam 2
        # second_range - atimam 3
        # word_counter - IoC WordCounter klase
        def initialize( first_range, second_range, word_counter )
            @word_map = Hash.new
            @ignore_database = Array.new
            @word_combinations_database =  Array.new
            @word_count = word_counter
            @first_range = first_range
            @second_range = second_range
        end
        
        #jei ignore reiksme parduodama kaip "plika" tai is jos padaromas
        #regexpas kad eilute sutaptu su pradzia ir pabaiga
        #jei jau yra naudojami $^ simboliai tai perduoti tokia kokia yra
        def ignore_database=(value)
            value.each{|x|
                @ignore_database << 
                    if x.index('^') == 0 or x.index('$') == x.size-1 
                        x
                    else
                        '^'+x+'$'
                    end
            }
        end
        
        def analyse_text( texts )  
            texts.each do |text|
                combinations = count_word_combinations( text )
                #ismesti rastas combinacijas kad dar karta nesuskaiciuotu
                combinations.each{|combination| text.gsub!( combination, '' ) }
                text.split.each do |w|
                    word = w.downcase.strip
                    word.sub!(':','') #sudinas budas isvalyt eilute nuo sudu
                    word.sub!('&quot;', '')
                    word.sub!('(', '')
                    word.sub!(')', '')
                    word.sub!(',', '')
                    word.sub!('„', '')
                    word.sub!('"','')
                    add_word( word ) unless word == '' or word.size < 3
                end
            end
        end
            
        def trim( word )
            case word.size
                when @first_range then word
                when @second_range then word[0..word.size-2]
                else word[0..word.size-3]
            end
        end
      
    private
        def add_word( word )
            trw = trim( word )
            @word_count.add( word, trw ) if @ignore_database.find{|x| word.match(x)}.nil?#if @ignore_database.index(trw).nil?
        end
       
        #ispradziu suskaiciuoti kiek zodziu kombinaciju yra is word_combinations_database ir
        #jas ismesti, tam kad nesiskaiciuotu dar karta
        def count_word_combinations( text )
            combinations = @word_combinations_database.find_all{|v| text.index( v )}
            combinations.each{|combination|
                add_word( combination )
            }
            return combinations
        end
    end
end
