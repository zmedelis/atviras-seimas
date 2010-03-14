require "rexml/document"

class KpiController < ApplicationController
  
  helper :sparklines

  def index
    doc = REXML::Document.new( File.new(File.join(RAILS_ROOT,'papildomi_duomenys', 'lrs_rss.pranesimai_spaudai')).read )
    @feed = Array.new
    doc.elements.each("//item") {|item|
      @feed << {:title=>item.elements['title'].text, :link => item.elements['link'].text, :date => item.elements['pubDate'].text[0..9]}
    }
    
    @trips = Trip.find(
      :all,
      :conditions => "to_days(now()) - to_days(start_date) <= 30",
      :order => 'start_date desc'
      )
      
    @sittings = Sitting.find(
      :all,
      :conditions => "to_days(now()) - to_days(date) <= 30",
      :order => 'date desc'
    )
    
    img_desc = File.new(File.join(RAILS_ROOT, 'papildomi_duomenys', 'dienos_nuotrauka.txt')).readlines
    @img_src = img_desc[0]
    @img_url = img_desc[1]
    @img_alt = img_desc[2]
  end
end
