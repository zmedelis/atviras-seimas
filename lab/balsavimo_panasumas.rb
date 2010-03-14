require 'rubygems'  
require 'active_record'  
require 'jcode'
$KCODE = 'u'

ActiveRecord::Base.establish_connection(  
  :adapter  => 'mysql',   
  :database => 'seimas',   
  :username => 'root',
  :encoding => 'utf8', 
  :password => '',   
  :host     => 'localhost')

class Politician < ActiveRecord::Base
  has_many :votes
end

class Vote < ActiveRecord::Base
  belongs_to :politician
  belongs_to :question
  ABSENT = 1
  NOVOTE = 2
  ABSTAIN = 3
  NO = 4
  YES = 5  
end

class Question < ActiveRecord::Base
  has_many :votes 
  belongs_to :sitting
end

class Sitting < ActiveRecord::Base
  has_many :questions
end

def sim_distance(mp1, mp2)
  match = 0
  count = 0
  mp1.votes.find(:all,:conditions=>["action != ?",Vote::ABSENT]).each do |v1|
    v2 = Vote.find(:first, :conditions => {:politician_id => mp2.id, :question_id => v1.question.id, :time=>v1.time})
    if v2 and v2.action != Vote::ABSENT then
  	  
      match += 1 if v1.action == v2.action
      count += 1
    end
    
  end
  match.to_f / count
end

p = Politician.find(936)
h = Hash.new
Politician.find(:all).each do |mp|
  s = sim_distance(p, mp)
  h[mp] = s unless s.nan?
end  

h.sort{|a,b| b[1]<=>a[1]}.each{|x,y| printf "#{x.last_name} - #{x.party_candidate}  #{y}\n"}