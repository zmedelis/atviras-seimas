RAILS_ENV = 'development'
require File.dirname(__FILE__) + "/../config/environment"
require 'jcode'
$KCODE = 'u'

require 'lrs/utils'

class DebateAnalyser
  include Utils


  def analyse(url)
    mp_speeches = Hash.new
    doc = utf_page url, true
    current_mp = nil # sneka galie eiti per kelis paragrafus, todel issaugom pradejusi sneketi
    sitting = (doc/"caption.pav").first.inner_text[/\d+/,0]
    (doc/"p.Roman").each do |el|
      line = el.inner_text
      speech = line
      m = line.match(/^\D\. (\D\.)?\w{4,}(-\w{4,})?/) # paskutine grupe (-\w+)? reikalinga kad pagauti tokius D. MEIŽELYTĖ-SVILIENĖ.
      pirminikas = line.match(/^PIRMININKAS/)
      current_mp = nil if pirminikas or (m and line.index(m[0]) == 0) # TODO kaip multiline rasti pirma pirmoj eilutei
      if current_mp.nil? and (m and line.index(m[0]) == 0) then
        speeker = m.to_s.split('.')
        speeker_first_name_initial = speeker.first.strip
        speeker_last_name = capitalize_name(speeker.last.strip)
        author_sql =<<-SQL
        select * from politicians
        where
          last_name = '#{speeker_last_name}' and
          (substring(first_name, 1,1) = '#{speeker_first_name_initial}' or substring(second_name, 1,1) = '#{speeker_first_name_initial}')
        SQL
        mp_speeker = Politician.find_by_sql(author_sql).first
        current_mp = mp_speeker
        speech = speech.index(').') ? speech[speech.index(').') + 2..speech.size] : speech[m.to_s.size+1..speech.size ] # ismetam pradzia Vardas Pavarde (Frak)     
      end
      #if current_mp then
        #mp_speeches[current_mp] = mp_speeches[current_mp] ? mp_speeches[current_mp] + ' ' + speech : speech
        (mp_speeches[current_mp] ||= []) << {:sitting => sitting, :speech => speech.gsub("\r\n", ' ')}if current_mp
      #end
    end
    mp_speeches
  end

private
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

da = DebateAnalyser.new
begin
dir = '/Users/zzygis/lab/db/www_lrs/'
out = '/Users/zzygis/lab/db/tekstai/stenogramos/'
Dir.foreach(dir){|f|
  if f.include? 'dokpaieska.showdoc_l?p_id=' then
    printf "#{f}\n"
    da.analyse(dir + f).each do |mp,s|
      s.each do |sp|
        FileUtils.mkdir_p out + mp.id_in_lrs.to_s
        file   = File.open(out + "#{mp.id_in_lrs}/#{sp[:sitting]}.txt", "a+")
        file << sp[:speech]
      end
    end    
  end
}
end
=begin
r = da.analyse('/Users/zzygis/lab/atviras-seimas/lab/tmp_data/dokpaieska.showdoc_l')
r.each do |mp,s|
  printf "\n#{mp.full_name}\n**********\n#{s.inspect}\n"
end
=end