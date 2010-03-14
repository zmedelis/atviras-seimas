require 'rubygems'
require 'hpricot'
require 'open-uri'

module Utils
  @@archyve = "../../db/www_lrs/"
  
  def denormalize( text )
    t = text.gsub("&amp;", "&").gsub('&nbsp;', ' ') #niekur nerandu kaip Hpricot'e ismesti spec simboliu pakeitimus
    t.gsub("\245", " ").gsub("\241", " ") #kazkokie keisti simboliai nulauziantys Iconv http://www3.lrs.lt/pls/inter/w5_sale.klaus_stadija?p_svarst_kl_stad_id=-1270
  end
  
  def utf_page(url, force_www = false)
    file =  @@archyve + url.gsub('/', '--') + '.html'
    if File.exist? file and not force_www
      page = File.read file
    else
      page = open(url).read
      unless force_www then
        f = File.new(file, 'w')
        f << page
      end
    end
    Hpricot(Iconv.new('utf-8', 'windows-1257').iconv(denormalize(page)))
  end  
end

