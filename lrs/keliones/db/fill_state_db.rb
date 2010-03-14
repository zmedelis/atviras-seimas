require 'rubygems'
require 'active_record'

class State < ActiveRecord::Base
end

ActiveRecord::Base.establish_connection({
      :adapter  => "mysql", 
      :database => "poldek",
      :socket   => "/opt/local/var/run/mysqld/mysqld.sock",
      :username => "",
      :password => "" 
})

File.new('valstybes-add-win.txt', 'r').each_line{|line|
  state_name, ioc, iso, state_fullname =  line.split(',')
  s = State.new
  s.name = 
    if state_fullname.strip.chomp == '-'
      state_name.strip.chomp
    else
      state_fullname.strip.chomp
    end
  s.iso_id = iso.strip
  s.save
}