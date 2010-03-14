# sugeneruoti ivairius HTML gabalus tam kad greiciau krautu puslapi

require 'active_record'
require 'app/models/trip'
require 'app/models/politician'
require 'app/models/mp_cache'


#suskaiciuojam bendra laika kiek seimo narys praleido komandiruotese
def mp_trip_duration
  Politician.find(:all).each do |mp|
    c = MpCache.new
    c.politician = mp
    i  = 0
    mp.trips.each do |t|
      i += (t.end_date - t.start_date).to_i
    end
    c.trip_duration = i
    c.save
  end
end
