require 'lrs/utils'

class DebateAnalyser
  include Utils
  
  def analyse(url)
    mp_references = {}
    doc = utf_page url
    current_mp = nil # sneka galie eiti per kelis paragrafus, todel issaugom pradejusi sneketi
    sitting = (doc/"caption.pav").first.inner_text[/\d+/,0]
    (doc/"p.Roman").each do |el|
      line = el.inner_text
      speech = line
      m = line.match(/^\D\.(\D\.)?\w+/)
      pirminikas = line.match(/^PIRMININKAS/)
      current_mp = nil if pirminikas or (m and line.index(m[0]) == 0) # TODO kaip multiline rasti pirma pirmoj eilutei
      if current_mp.nil? and (m and line.index(m[0]) == 0) then
        current_mp = find_mp m.to_s 
        puts "----- #{current_mp.full_name}"
        speech = speech.index(').') ? speech[speech.index(').') + 2..speech.size] : speech[m.to_s.size+1..speech.size ] # ismetam pradzia Vardas Pavarde (Frak)     
        puts "#{speech}"
        #nuorodos i kitus seimo narius
        speech.scan( /( \D\.(\D\.)?\w+)/ ).each do |mp|
          name = strip_last_name mp[0].strip
          
          first_name_initials = name.split('.').first
          last_name = name.split('.').last
          reference_sql=<<-SQL
          select * from politicians
          where
            last_name like '#{last_name + '%'}' and
            (substring(first_name, 1,1) = '#{first_name_initials}' or substring(second_name, 1,1) = '#{first_name_initials}')
          SQL
          ref_mp = Politician.find_by_sql(reference_sql).first
          puts "\tradom #{ref_mp.full_name}"
          (mp_references[current_mp] ||= []) << {:name_reference_id => ref_mp.id, :sitting_id=>sitting}
        end     
      end
    end
    mp_references
  end
  
private
  def find_mp(name)
    speeker = name.split('.')
    speeker_first_name_initial = speeker.first
    speeker_last_name = capitalize_name(speeker.last)
    author_sql =<<-SQL
    select * from politicians
    where
      last_name = '#{speeker_last_name}' and
      (substring(first_name, 1,1) = '#{speeker_first_name_initial}' or substring(second_name, 1,1) = '#{speeker_first_name_initial}')
    SQL
    Politician.find_by_sql(author_sql).first  
  end
  
  def strip_last_name(name)
    name.gsub(/(ai|as|ą|čiui|čio|is|io|į|iuj|iu|iaus|iui|ius|ių|iumi|os|iaus|o|u|ui|ys)$/, '').gsub(/(|ė|ės|ei|e|ę|a)$/, '')
  end

  def capitalize_name(name)
    c_name = ''
    index = 1
    name.each_char{ |char|
      n =  index == 1 ? char : char.downcase.tr("ĄČĘĖĮŠŲŪŽ","ąčęėįšųūž")
      c_name += n
      index += 1
    }
    c_name
  end
end
=begin
Test selektas
select src.last_name as a, ref.last_name as b
from debate_references, politicians as src, politicians as ref
where debate_references.politician_id = src.id and
debate_references.name_reference_id = ref.id
=end
#DebateReference.delete_all
#DebateAnalyser.new.analyse 'http://www3.lrs.lt/pls/inter3/dokpaieska.showdoc_l?p_id=324770'
