#!/usr/bin/env ruby
RAILS_ENV = 'development'
require File.dirname(__FILE__) + "/../../config/environment"

require 'rubygems'
require 'active_record'
require 'hpricot'
require 'open-uri'
require 'json'
require 'uri'
require 'lrs/utils'

include Utils

LRS_URL = "http://www3.lrs.lt/pls/inter/"

#pareigybiu tipai
KOMITETAS = "komitetas"
PAKOMITETIS = "pakomitetis"
KOMISIJA = "komisija"
FRAKCIJA = "frakcija"
GRUPE = "grupe"
VALDYBA = "valdyba"
VADOVYBE = "vadovybe"
SEIMAS = "seimas"

class ParseMP
  attr_reader :mp
  
  def parse(url)
    @doc = utf_page url, true
    @mp = Politician.find_by_id_in_lrs(url.match(/(p_asm_id=)(\d+)/)[2])
    if @mp then  #jei toks yra ji istrinam ir perkuriam
      printf "SENAS politikas #{@mp.full_name} jau yra atnaujinam info\n"
      @mp.positions.clear
      @mp.save
    else
      printf "NAUJAS politikas #{url.match(/(p_asm_id=)(\d+)/)[2]}\n"
      @mp = Politician.new
    end
    
    @mp.id_in_lrs = url.match(/(p_asm_id=)(\d+)/)[2]
    personal_info
    roles
    @mp.save
  end
  
  def personal_info()
    
    # randam seimo nario varda
    re_name = /(2008-2012 m. kadencijos Seimo nar(ė|ys) )(.+)/
    @doc.search("/html/body/center/table/tr[2]/td/div/table/tr/td[3]/div/div[2]/center/table/tr/td/table/tr/td[2]/table/tr/td[2]/div").each do |x|
      txt = x.inner_text
      name = txt.match(re_name)
      if name then
        #unikodas noramliai nepalaikomas
        #sudu kruva
        full_name = ''
        name[3].split.each { |part|
          index = 1
          part.each_char{ |char|
            n =  index == 1 ? char : char.downcase.tr("ĄČĘĖĮŠŲŪŽ","ąčęėįšųūž")
            full_name += n
            index += 1
          }
          full_name += ' '
        }
        #printf "Vardas '#{full_name.strip}'\n" 
        fn = full_name.split
        @mp.first_name = fn[0]
        if fn.size == 2 then
          @mp.last_name = fn[1]
        end
        if fn.size == 3 then
          @mp.second_name = fn[1]
          @mp.last_name = fn[2]
        end
      end
    end
    
    # visa info pilkoje dezuteje i desine nuo foto
    re_email = /(Asmeninis elektroninis paštas: )(.+@lrs.lt)/
    re_fromto = /(Seimo nar(ys|ė)  nuo )(\d{4}-\d{2}-\d{2})( iki )(\d{4}-\d{2}-\d{2})/
    re_from = /(Seimo nar(ys|ė)  nuo )(\d{4}-\d{2}-\d{2})/
    re_district = /(Išrinkt(as|a) +)(.+)(apygardoje|pagal sąrašą)/
    re_party = /(iškėlė +)(.+)(Kandidato puslapis)/
    
    @doc.search("/html/body/center/table/tr[2]/td/div/table/tr/td[3]/div/div[2]/center/table/tr/td/table/tr/td[2]/table/tr[2]/td[2]").each do |x|
      txt = x.inner_text
      email = txt.match(re_email)
      fromto = txt.match(re_fromto)
      from = txt.match(re_from)
      district = txt.match(re_district)
      party = txt.match(re_party)

      @mp.email = email[2].strip if email
      @mp.constituency = district[3].strip if district
      @mp.party_candidate = party[2].strip if party
      
      position = Position.new
      position.from = from[3] if from
      position.to = fromto[5] if fromto
      position.description = "2004-2008 Seimo kadencija"
      position.title = "Seimo narys"
      position.department = SEIMAS
      @mp.positions << position
  
      #printf "nuo '#{from[3]}'\n" if from
      #printf "iki '#{fromto[5]}'\n" if fromto
      #printf "email '#{email[2]}'\n" if email
      #printf "isrinktas '#{district[3]}'\n" if district
      #printf "tipas '#{district[4]}'\n" if district
      #printf "iskele '#{party[2]}'\n" if party
    end
  end

  def roles()
    re_from = /(nuo +)(\d{4}.\d{2}.\d{2})/
    re_to = /(iki +)(\d{4}.\d{2}.\d{2})/
    @doc.search("/html/body/center/table/tr[2]/td/div/table/tr/td[3]/div/div[2]/center/table//li").each do |x|
      txt = x.inner_text.squeeze(" ")
      roleType = KOMITETAS    if txt.include? "komitetas,"
      roleType = PAKOMITETIS  if txt.include? "pakomitetis,"
      roleType = KOMISIJA     if txt.include? "komisija,"
      roleType = FRAKCIJA     if txt.include? "frakcija," or
                                  txt.include? "Mišri Seimo narių grupė," or
                                  txt.start_with? "Frakcija"
      roleType = GRUPE    if (txt.include? "grupė," and not txt.include? "Mišri Seimo narių grupė,") or
                            txt.include? "Seniūnų sueiga," or
                            txt.include? "narių asamblėjoje," or
                            txt.include? "Asamblėjoje"
      roleType = VALDYBA  if txt.include? "Seimo valdyba,"
      #seimo vadovybe arba pirminikas arba jo pavaduotojai
      roleType = VADOVYBE if txt.include? "Seimo Pirminink" or 
                            (txt.include? "Seimo Pirminin" and txt.include? "pavaduotoj")
      #darbo pavadinimas / kadangi VADOVYBE neturi linko tai apdorojam kitaip
      if roleType then
        position = Position.new
        from = txt.match re_from
        to = txt.match re_to

        position.description = 
          roleType != VADOVYBE ? x.search('//a').first.inner_text.squeeze(" ") : 
          txt.sub(/\(.+\)/, '') #kadangi cia datos yra stringe, ismetam viska tarip skalustu
        position.department = roleType    
        #dabar dar surandam kokia pozicija uzime: narys, seniunas, pirmininkas
        position.title =  txt.sub(position.description, '').sub(/\(.+\)/, '').sub(',', '').strip				
        
        #kadangi kai kurios datos yra tokio formato YYYY MM DD
        #pakeiciam i YYYY-MM-DD kuris iskart konvertinamas i Date
        position.from = from[2].gsub ' ', '-' if from
        position.to = to[2].gsub ' ', '-' if to
        @mp.positions << position
		
        #printf "#{roleType}: #{position.description}"
        #printf " FROM: #{position.from}" 
        #printf " TO: #{position.to}"
        #printf " POSITION: #{position.title}"
        #printf "\n"
      end
    end
  end
end

#Politician.delete_all
#Position.delete_all

parser = ParseMP.new
doc = utf_page "http://www3.lrs.lt/pls/inter/w5_show?p_r=6113&p_k=1", true
doc.search("/html/body/center/table/tr[2]/td/div/table/tr/td[3]/div/div[2]/center/table//a").each do |mp_link|
  href = mp_link.attributes['href']
  
  if href and href.include? 'p_asm_id='
    #sleep 3
    parser.parse LRS_URL + href
  end
end

