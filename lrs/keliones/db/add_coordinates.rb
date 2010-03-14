require 'rubygems'
require 'active_record'

class State < ActiveRecord::Base
  has_one :coordinate
end

class Coordinate < ActiveRecord::Base
  belongs_to :state
end

ActiveRecord::Base.establish_connection({
      :adapter  => "mysql", 
      :database => "poldek",
      :socket   => "/opt/local/var/run/mysqld/mysqld.sock",
      :username => "",
      :password => "" 
})

File.new('db/country-LatLon.txt', 'r').each_line{|line|
  iso, lat, lon =  line.split(',')
  
  s = State.find_by_iso_id(iso)
  if s
    c = Coordinate.new
    c.lat = lat
    c.lon = lon.chomp
    s.coordinate = c
    s.save
  else
    puts iso + " nerastas"
  end
}