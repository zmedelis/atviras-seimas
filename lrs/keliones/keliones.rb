RAILS_ENV = 'development'
require File.dirname(__FILE__) + "/../../config/environment"

require 'rubygems'
require 'active_record'
require 'hpricot'
require 'open-uri'
require 'uri'
require 'lrs/utils'
require 'lrs/keliones/cache_generator'

require 'app/models/trip'
require 'app/models/state_label'
require 'app/models/state'
require 'app/models/politician'


class TripScraper
  
  include Utils
  @@WWW = 'http://www3.lrs.lt/pls/inter/'
  # parsinam pagrindini puslapi kuriame yra seimunu
  # sarasas su nuorodom i ju asmeninius kelioniu puslapius
  def mp_trip_pages
    pages = Hash.new
    doc = utf_page "w5_show?p_r=6151&p_k=1"
                    
    doc.search("//a[@class='doc_l']").each do |x|
      mp_name = x.inner_text # cia vardas su skliaustuose esanciu kelioniu skaicum Vardas Pavarde (3/1)
      if mp_name.include? ')'
        pages[mp_name[0,mp_name.index('(')-1]] = denormalize( x.attributes['href'] )
      end
    end
    return pages
  end
  
  #isparsinti seimo nario komandiruociu puslapi
  def mp_business_trip(mp, page)
    doc = utf_page page
    #printf "mp from db #{page.match(/(p_asm_id=)(\d+)/)[2]} \n"
    trip_list = doc.at("//div[@id='divDesContent']")
    (trip_list/:table).each do |trip|
      trip_desc = (trip/:td)[1].inner_text.gsub("\n", " ") #ismest visus new line
      #1. backref istraukia sali - ?!.* reiskia rasti tik paskutini elementa, siuo atveju paskutini skliausteli
      #2. backref istraukia keliones pradzios data
      #3. backref istraukia keliones pabaigos data
      description = trip_desc.match(/(?!.*\()(\D+)\), (\d{4}-\d{2}-\d{2})–(\d{4}-\d{2}-\d{2})/)
      # splitinti per kablelius nes kartais vizitas buna aprasytas ne kaip (Latvijos Respublika)
      # o kaip (Latvijos Respublika, Estijos Respublika)
      description[1].split(', ').each do |visited_state|
        printf "#{visited_state}\n"      
        st = StateLabel.find_by_label(visited_state).state
        if st
          t = Trip.create(
            :state => st,
            :kind => 'komandiruote',
            :politician => Politician.find_by_id_in_lrs(page.match(/(p_asm_id=)(\d+)/)[2]),
            :start_date => Date.strptime(description[2], "%Y-%m-%d"),
            :end_date => Date.strptime(description[3], "%Y-%m-%d") )

        else
          printf "KLAIDA #{mp.name_in_reports} '#{description[1]}' NERASTA !!!!!!!!!!!!!!!!!!\n"
        end
      end
    end
  end
  
  #pagrindinis metodas, surinkti visus seimo nariu puslapius juos
  #isparsinti ir supusti i DB
  def scrap_trip_pages
    
    mp_trip_pages.each do |mp, trip_page|
      printf "mp - #{mp}\n"
      doc = utf_page(trip_page)
      t = Time.now
      komandiruotes = (doc/"//a[text()='Komandiruotės']").first
      mp_business_trip(mp, denormalize( komandiruotes.attributes['href']  ) ) if komandiruotes
      printf "Laikas: #{Time.now - t}\n"
      #sleep 3
    end
    
  end

  private
  #atidarom psl normaliu UTF enkodingu
  def utf_page(url)	
    Hpricot(Iconv.new('utf-8', 'windows-1257').iconv(open(@@WWW+url).read))
  end
end  

Trip.delete_all
MpCache.delete_all
scraper = TripScraper.new
scraper.scrap_trip_pages

#cache regeneration
mp_trip_duration
