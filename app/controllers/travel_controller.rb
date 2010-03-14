class TravelController < ApplicationController  
  def lrsmap
    @travelers = Politician.find(:all, :include => [:trips], :order =>'last_name')
  end

  def lrslist
    @states = State.find(:all, :include => [:trips, :state_labels]).sort{|x,y| y.trips.size <=> x.trips.size}
    @travelers = Politician.find(:all, :include => [:trips])
  end

  def filter_by_mp
    @mp = Politician.find( params[:traveler][:id][0] ).id_in_lrs
  end

  def index
    @travelers = Politician.find(:all, :include => [:trips], :order =>'last_name')
  end
end
