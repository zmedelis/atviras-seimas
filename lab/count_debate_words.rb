RAILS_ENV = 'development'
require File.dirname(__FILE__) + "/../config/environment"

class FileLinesExtractor
  def extract(f, rule=nil)
      lines = Array.new
      File.open(f).each_line{|line|
          lines << line.chomp if rule.nil? or line[rule]
      }
      return lines
  end
end

#iteruojam per stenogramu failus
#perduoti bloka
def count
  dir = '/Users/zzygis/lab/tekstai/stenogramos/'
  Dir.foreach(dir) do |f_sn|
    current_dir = dir + f_sn + '/'
    if current_dir =~ /\d+/ then
      Dir.foreach(dir + f_sn) do |f_sp| 
        yield f_sn, current_dir + f_sp if f_sp.include? '.txt'
      end
    end
  end
end

#suskaiciuojam kiek kartu seimo narys kreipesi i kita seimo nari
def count_debate_references
  extr = FileLinesExtractor.new
  mp_refs = {} # cia bus sumesti visi SN vardai i kuriuos buvo kreiptasi
  count do |mp, sten|
    puts "#{mp}"
    extr.extract(sten).each do |line|
      line.scan(/( \D\.(\D\.)?\w{4,})/).each do |ref|
        puts "\t#{ref}"
        (mp_refs[mp] ||= []) << ref[0].strip if ref[0].strip.size > 4
      end
    end
  end
  
  #TODO sitas turetu eiti i kita vieta (t.y. i lrs moduli), bet kolkas nera architekturos kaip tvarkyti stenogramas
  DebateReference.delete_all
  mp_refs.each{|p,ref|
    author = Politician.find_by_id_in_lrs(p)
    ref.each{|ref|
      name = ref.gsub(/(ai|as|ą|čiui|čio|is|io|į|iuj|iu|iaus|iui|ius|ių|iumi|os|iaus|o|u|ui|ys)$/, '').gsub(/(|ė|ės|ei|e|ę|a)$/, '')
      
      first_name_initials = name.split('.').first
      last_name = name.split('.').last
      reference_sql=<<-SQL
      select * from politicians
      where
        last_name like '#{last_name + '%'}' and
        (substring(first_name, 1,1) = '#{first_name_initials}' or substring(second_name, 1,1) = '#{first_name_initials}')
      SQL
      ref_mp = Politician.find_by_sql(reference_sql).first      
      author.debate_references << 
        author.debate_references.new(:name_reference_id => ref_mp.id, :sitting_id=>nil) if ref_mp
    }
  }
end

def count_words
  dir = '/Users/zzygis/lab/tekstai/lit/'
  out = File.open 'zodziukiekis.csv', 'w'
  extr = FileLinesExtractor.new
  words = Hash.new
  Dir.foreach(dir) { |f|
    extr.extract(dir + f).each { |l|
      l.split(' ').each{ |word|
        if word =~ /\w+/ then
          w = word.chomp.gsub(/(\.|,|:|\?|;|–)/, '')
          words[w] = words[w] ? words[w] + 1 : 1
        end 
      }
    } if f.include? 'txt'
  }
  words.each{|w,c| out << "#{w}\t#{c}\n"}
end

def matrix
  word_range_up = 0.0005 # neimam pirmu ir paskutiniu 10% dazniausiai ir reciausiai pasikartojanciu zodziu
  word_range_down = 0.99
  out = File.open 'zodziai.csv', 'w'
  extr = FileLinesExtractor.new
  mp_word_counter = {}
  all_words_count = 0
  all_words = {}
  all_words_sorted = nil
  count { |mp, sten|
    extr.extract(sten).each do |l|
      l.downcase.gsub(/(\.|,|:|\?|;|–)/, '').split(' ').each { |word|
        mp_word_counter[mp] ||= Hash.new { |h,k| h[k] = 0 }
        word_counter = mp_word_counter[mp]
        word_counter[word] =  word_counter[word] ? word_counter[word] + 1 : 1
        all_words[word] = all_words[word] ? all_words[word] + 1 : 1# << word unless all_words.include? word
        all_words_count += 1
      }
    end
  }
  
  #all_words_sorted = all_words.delete_if{|w,c| c < word_limit}.sort{|a,b| b[1] <=> a[1]} 
  all_words_sorted = all_words.sort{|a,b| b[1] <=> a[1]} 
  puts "VISI: #{all_words.size}"
  #imam pasyva be min max % 
  all_words_sorted_and_extremes_removed = 
    all_words_sorted[word_range_up*all_words_sorted.size..(1-word_range_down)*all_words_sorted.size]
  puts "VISI-EXTREME: #{all_words_sorted_and_extremes_removed.size}"    
    
  out << "sn\t"
  all_words_sorted_and_extremes_removed.each do |w,c|
    out << "#{w}\t"
  end
  out << "\n"
  mp_word_counter.each do |mp, words|
    sum = 0
    words.each{|w,c| sum += c}
    if all_words_count / 141 / 2 < sum then
      p = Politician.find_by_id_in_lrs(mp)
      if p.current_positions_by_type('seimas').size > 0 then
        out << "#{p.full_name} (#{p.current_political_group.code if p.current_political_group})\t"
        all_words_sorted_and_extremes_removed.each do |w,c|
          out << "#{words[w]}\t"
        end
        out << "\n"
      end
    end
  end
end

count_debate_references

