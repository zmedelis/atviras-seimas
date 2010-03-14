class QuestionsController < ApplicationController
  helper :sparklines
  
  def index
    @questions = Question.find :all
  end

  def auto_complete_for_politician_full_name
    search = params[:politician][:full_name]
    @politicians = Politician.find(:all, 
      :conditions => [ 'LOWER(last_name) LIKE ?',
      search + '%' ], 
      :order => 'last_name ASC',
      :limit => 8)

    render :partial => "politicians"
  end  
  
  def search
    full_name = params[:politician][:full_name].gsub('_', ' ') 
    re = Regexp.new(params[:search], Regexp::IGNORECASE)
    votes = Politician.find_by_full_name(full_name).votes #Vote.find(:all, :conditions=>{:politician_id=>Politician.find_by_full_name(full_name).id})
    #TODO db statistikas skaiciuojant susikami balsavimai todel production yra v.question != nil 
    # butinai sutvarkyt, perskaicuot db gal
    @mp_votes = votes.delete_if{|v| v.question == nil or not v.question.formulation =~ re}.sort{|x,y| y.action <=> x.action}
    
    respond_to { |format|
      format.html {render :partial => 'search_results'}
      format.xml  {render :xml  => @mp_votes.to_xml()} 
      format.json {render :json => @mp_votes.to_json() }      
    }    
  end

  def filter
    vote_questions = Question.find_questions_with_votes(params[:vote].to_f)
    speech_questions = Question.find_questions_with_speeches(params[:speech].to_f)
    attendance_questions = Question.find_questions_with_attendances(params[:attendance].to_f)
    rebellion_questions = Question.find_questions_with_rebellion(params[:rebellion].to_f)
    
    @questions = Array.new
    (vote_questions & speech_questions & attendance_questions & rebellion_questions).each do |qid|
      @questions << Question.find(qid, :include=> [:sitting])
    end
    
    x = (vote_questions & speech_questions & attendance_questions & rebellion_questions)
    render :partial => 'question', :locals => {
      :rebellion_questions => rebellion_questions,
      :speech_questions => speech_questions,
      :vote_questions => vote_questions,
      :attendance_questions => attendance_questions
      }
  end

  def show
    @question = Question.find_by_sid params[:id]
    @voting_rounds = @question.votes.group_by(&:time)
    
    respond_to { |format|
      format.html
      format.xml  {render :xml  => @question.to_xml(:include => :votes)} 
      format.json {render :json => @question.to_json(:include => :votes) }      
    }     
  end
end
