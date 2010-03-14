class StateUnion < ActiveRecord::Base
  has_many :states
  
  def trips
    trips = []
    states.each{|st| trips << st.trips }
    return trips.flatten
  end
end
