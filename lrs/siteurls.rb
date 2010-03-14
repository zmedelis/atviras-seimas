#!/usr/bin/env ruby
require File.dirname(__FILE__) + "/../config/environment"

#{Time.now.strftime('%Y-%m-%d')}
def url(addr)
  "http://seimas.idemokratija.info/#{addr}\n"
end

sitemap = File.new("urls.txt", 'w');

sitemap << url("")
sitemap << url("komandiruotes")
sitemap << url("seimo_nariai")
sitemap << url("klausimai")
Politician.find(:all).each{|p| sitemap << url("seimo_nariai/politikas/#{p.name_as_id}")}
