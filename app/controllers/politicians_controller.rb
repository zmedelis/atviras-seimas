class PoliticiansController < ApplicationController
  helper :sparklines


  def index
    politicians = Politician.find :all 
    @politicians_active = politicians.reject{|mp| mp.current_positions_by_type('seimas').size == 0 }
    @politicians_inactive = politicians.reject{|mp| mp.current_positions_by_type('seimas').size > 0 }
    respond_to { |format|
      format.html
      format.xml  {render :xml  => politicians.to_xml(:include => :positions)} 
      format.json {render :json => politicians.to_json(:include => :positions) }      
    }  
  end
  
  def show
    full_name = params[:id].gsub('_', ' ')
    @politician = Politician.find_by_full_name(full_name)
    @current_group = @politician.positions_by_type('frakcija').first
    
    @attended = @politician.attendances.reject{|a| not a.present}.size
    @all_attendances = @politician.attendances.size
    @attendance_rank = @politician.rank_attendance
    @attendance_history = @politician.history_attendance
    @attendace_avg = @politician.avg_score_attendance
    
    @voted =  @politician.votes.reject{|a| a.group_rebellion.nil?}.size
    @all_votes = @politician.votes.size
    @vote_rank = @politician.rank_vote
    @vote_history = @politician.history_vote 
    @vote_avg = @politician.avg_score_vote
    
    @spoke =  @politician.speeches.size
    @all_speeches = Speech.count(:all)
    @speech_rank = @politician.rank_speech
    @speech_history = @politician.history_speech
    @speech_avg = @politician.avg_score_speech

    active = @politician.votes.reject{|a| a.group_rebellion.nil?}
    @active_votes = active.size
    @group_rebellions = @active_votes - active.reject{|a| not a.group_rebellion}.size
    @group_rebellion_rank = @politician.rank_rebellion_group()
    @parliament_rebellions = @active_votes - active.reject{|a| not a.parliament_rebellion}.size
    @parliament_rebellion_rank = @politician.rank_rebellion_parliament()
    @group_rebellion_history = @politician.history_group_rebellion
    @parliament_rebellion_history = @politician.history_parliament_rebellion
    @parliament_rebellion_avg = @politician.avg_parliament_rebellion
    @group_rebellion_avg = @politician.avg_group_rebellion
    
    respond_to { |format|
      format.html
      format.xml  {render :xml  => @politician.to_xml(:include => :positions)} 
      format.json {render :json => @politician.to_json(:include => :positions) }      
    }
  end
end
