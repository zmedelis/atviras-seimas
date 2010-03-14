class Politician < ActiveRecord::Base
  
  #has_many :name_references, :through => :debate_references
  has_many :debate_references, :dependent => :destroy
  
  #has_many :similar_voters, :through => :vote_patterns
  has_many :vote_patterns, :dependent => :destroy, :order => 'score'
  
  has_many :positions, :dependent => :destroy
  has_many :speeches, :dependent => :destroy
  has_many :attendances, :dependent => :destroy
  has_many :votes, :dependent => :destroy
  has_many :trips, :dependent => :destroy
  has_one :mp_cache #TODO sita keisti
  
  def self.find_by_full_name( name_in_full )
    buf = name_in_full.split
    if buf.size == 2 then
      return Politician.find(:first, :conditions => "first_name = '#{buf[0]}' AND second_name is NULL AND last_name = '#{buf[1]}'")
    end
    if buf.size == 3 then
      return Politician.find(:first, :conditions => "first_name = '#{buf[0]}' AND second_name = '#{buf[1]}' AND last_name = '#{buf[2]}'")
    end
    return nil
  end
  
  def full_name
    buf = first_name + ' '
    buf += second_name + ' ' if second_name
    buf += last_name
    buf
  end

  def name_as_id
    full_name.gsub(' ', '_')
  end
  
  def semi_full_name
    buf = first_name.first + '. '
    buf += second_name.first + '. ' if second_name
    buf += last_name
    buf    
  end
  
  def positions_by_type( type )
    positions.reject{|x| x.department != type}
  end
  
  def current_positions
    positions.reject{|x| x.to != nil}
  end
  
  def current_positions_by_type( type )
    current_positions.reject{|x| x.department != type}
  end
  
  def name_of_current_political_group
    p = current_positions_by_type('frakcija').first
    p.nil? ? '': p.description
  end

  def current_political_group
    sn = name_of_current_political_group
    PoliticalGroup.find_by_name(sn)
  end
  
  def similarities_by_votes
    mps = Hash.new
    vote_patterns.each{ |vp|
      mps[Politician.find(vp.similar_voter_id)] = vp.score * 100
    }
    mps.reject{ |mp,x| mp.current_positions_by_type('seimas').size == 0}
  end
  
  def similarities_by_jobs
    friends = Hash.new
    current_positions.each{|position|
      positions = Position.find(:all, 
        :conditions => "politician_id != #{id} AND description = '#{position.description}' AND description != '2004-2008 Seimo kadencija' AND `to` is null")
      positions.each{|pp|
        x = friends[pp.politician]
        x = x.nil? ? 1 : x + 1 
        friends[pp.politician] = x
      }
    }
    return friends.reject{ |mp,x| mp.current_positions_by_type('seimas').size == 0}
  end

  def similarities_by_references
    refs = Hash.new
    DebateReference.count(
      :all,
      :conditions=>{:politician_id => id},
      :group => :name_reference_id).each do
      |mp, ref|
        refs[Politician.find(mp)] = ref
      end
      refs.reject{ |mp,x| mp.current_positions_by_type('seimas').size == 0}
  end
  
#### Eiliskumas ####  
  def rank_rebellion_group
    sql=<<-SQL
    select
      politician_id,
      sum(
        case group_rebellion
          when true then 1
          when false then 0
        end  
      ) / count(*) as sant
    from votes 
    where group_rebellion is not null
    group by politician_id order by sant asc
    SQL
    rank sql
  end
  
  def rank_rebellion_parliament
    sql=<<-SQL
    select
      politician_id,
      sum(
        case parliament_rebellion
          when true then 1
          when false then 0
        end  
      ) / count(*) as sant
    from votes 
    where parliament_rebellion is not null
    group by politician_id order by sant asc
    SQL
    rank sql
   end
  
  def rank_vote
    sql=<<-SQL
    select politician_id,
        sum(
        case action
          when 1 then 0
          when 2 then 0
          when 3 then 1
          when 4 then 1
          when 5 then 1
        end
        ) / count(*) as sant
    from votes group by politician_id order by sant desc
    SQL
    rank sql
  end
   

   
   def rank_attendance
     sql=<<-SQL
     select politician_id,
         sum(
         case present
           when true then 1
           when false then 0
         end
         ) / count(*) as sant
     from attendances group by politician_id order by sant desc
     SQL
     rank sql
   end
   
   def rank_speech
     #TODO dabar paima visus SN net tuos kurie nebe seime (160)
     sql=<<-SQL
     select politicians.id, count(politician_id) as sp
     from politicians
     left join speeches
     on politicians.id = politician_id
     group by politicians.id order by sp desc
     SQL
     rank sql
   end
   
#### Istorijos ####        
       
  def history_vote
    sql=<<-SQL
    select
    sum(
    case action
      when 1 then 0
      when 2 then 0
      when 3 then 1
      when 4 then 1
      when 5 then 1
    end
    ) / count(*) as sant
    from sittings, votes, questions
    where
      votes.question_id = questions.id and questions.sitting_id = sittings.id and votes.politician_id = #{id}
    group by politician_id,  date_format(date, '%Y %m')
    order by date_format(date, '%Y %m')
    SQL
    history sql
  end

  def history_attendance
    sql=<<-SQL
    select
    sum(
    case present
      when true then 1
      when false then 0
    end
    ) / count(*) as sant
    from sittings, attendances
    where
      attendances.sitting_id = sittings.id  and politician_id = #{id}
    group by politician_id,  date_format(date, '%Y %m')
    order by date_format(date, '%Y %m')
    SQL
    history sql
  end
  
  def history_speech
    sql=<<-SQL
    select
    count(*) as sp
    from speeches, sittings, questions
    where
      speeches.question_id = questions.id and questions.sitting_id = sittings.id and speeches.politician_id = #{id}
    group by politician_id,  date_format(date, '%Y %m')
    order by date_format(date, '%Y %m')
    SQL
    history sql
  end
  
  def history_parliament_rebellion
    sql=<<-SQL
    select
      1 - sum(
        case parliament_rebellion
          when true then 1
          when false then 0
        end  
      ) / count(*) as sant
    from sittings, votes, questions 
    where 
      votes.parliament_rebellion is not null and
      votes.question_id = questions.id and questions.sitting_id = sittings.id and
      votes.politician_id = #{id}
    group by politician_id,  date_format(date, '%Y %m')
    order by date_format(date, '%Y %m')
    SQL
    history sql  
  end

  def history_group_rebellion
    sql=<<-SQL
    select
      1 - sum(
        case group_rebellion
          when true then 1
          when false then 0
        end  
      ) / count(*) as sant
    from sittings, votes, questions 
    where 
      votes.group_rebellion is not null and
      votes.question_id = questions.id and questions.sitting_id = sittings.id and
      votes.politician_id = #{id}
    group by politician_id,  date_format(date, '%Y %m')
    order by date_format(date, '%Y %m')
    SQL
    history sql
  end
  
#### Vidurkiai ####
#TODO sitie turetu buti self
  
  def avg_score_vote
    sql=<<-SQL
    select
    sum(
    case action
      when 1 then 0
      when 2 then 0
      when 3 then 1
      when 4 then 1
      when 5 then 1
    end
    ) / count(*) as sant
    from votes
    SQL
    (ActiveRecord::Base.connection.execute(sql).fetch_row[0].to_f * 100).round
  end 
  
    
  def avg_score_attendance
    sql=<<-SQL
    select
    sum(
    case present
      when true then 1
      when false then 0
    end
    ) / count(*) as sant
    from sittings, attendances
    where
      attendances.sitting_id = sittings.id
    SQL
    (ActiveRecord::Base.connection.execute(sql).fetch_row[0].to_f * 100).round
  end  
  
  def avg_score_speech
    Politician.count(:all).to_f / Speech.count(:all)
  end
  
  def avg_parliament_rebellion
    sql=<<-SQL
    select
    1 - sum(
      case parliament_rebellion
        when true then 1
        when false then 0
      end
    ) / count(*) as sant
    from sittings, votes, questions
    where
      votes.parliament_rebellion is not null and votes.question_id = questions.id and questions.sitting_id = sittings.id
    SQL
    avg sql
  end
  def avg_group_rebellion
    sql=<<-SQL
    select
    1- sum(
      case group_rebellion
        when true then 1
        when false then 0
      end
    ) / count(*) as sant
    from sittings, votes, questions
    where
      votes.group_rebellion is not null and votes.question_id = questions.id and questions.sitting_id = sittings.id
    SQL
    avg sql
  end  

private

  def history(sql)
    history = Array.new
    r = ActiveRecord::Base.connection.execute(sql)
    while row = r.fetch_row do history << (row[0].to_f * 100).round end
    history  
  end
  
  def avg(sql)
    (ActiveRecord::Base.connection.execute(sql).fetch_row[0].to_f * 100).round
  end
  
  #paskaiciuojam eiliskuma, iskaitant tuos atvejus kai dalinamos vietos
  #t.y. seimo narys dalinasi 5ta 11ta vieta su kitais 6 seimo nariais
  def rank(sql)
    ranges = Array.new
    current_range = nil
    value = -1
    index = 1
    rank_index = 0
    stop_index = false
    r = ActiveRecord::Base.connection.execute(sql)
    while row = r.fetch_row do
      rank_index += 1 unless stop_index
      stop_index = row[0].to_i == id if not stop_index

      unless value == row[1].to_f then
        value = row[1].to_f
        ranges << current_range if current_range
        current_range = Range.new(index, index)
      else
        current_range = Range.new( current_range.first, current_range.end + 1)
      end
      index += 1
    end
    ranges << current_range if current_range

    ranges.each do |range|
       return range if range.include? rank_index
    end

    Range.new(-1, -1)
  end  
end
