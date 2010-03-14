class DataServiceController < ApplicationController

	def index
	end

  def lrs_mps
    @mps = Politician.find(:all)
    render :layout => false
  end

  def trips_by_mp
    @mp = Politician.find_by_id_in_lrs( params[:sn] )
    @states = State.find(:all, :include => [:trips], :conditions => ['trips.politician_id = ?', @mp.id])
    render :layout => false	 
  end

  def trips_in_state
    id = params[:iso]
    group = StateUnion.find_by_iso(id)
    @destination = group ? group : State.find_by_iso_id(id) 

    render :layout => false
  end

  def trips
    @grouped_states = Hash.new
    StateUnion.find(:all).each do |group|
      @grouped_states[group] =  
      State.find(:all, :conditions => ["state_union_id = ?", group.id]).reject{
        |s| s.trips.count < 1
      }
    end

    @grouped_states.default = 
    State.find(:all, :conditions => ["state_union_id is NULL"]).reject{
      |s| s.trips.count < 1
    }
     
    render :layout => false
  end
end
