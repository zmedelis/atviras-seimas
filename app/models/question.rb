class Question < ActiveRecord::Base
  
  #TODO stage: dabar 'Svarstymas' 'Priėmimas' bet buna ir 'grazinta ....' http://www3.lrs.lt/pls/inter/w5_sale.klaus_stadija?p_svarst_kl_stad_id=-2675

  belongs_to :sitting
  has_many :votes, :dependent => :destroy 
  has_many :political_group_votes, :dependent => :destroy
  has_many :speeches, :dependent => :destroy

  def self.find_questions_with_rebellion(min_rebellion)
    questions = Array.new
    ParliamentVote.find(:all).each do |pv|
      qid = pv.question_id
      aye = pv.action_yes
      nay = pv.action_no
      min = aye <= nay ? aye : nay
      max = aye >= nay ? aye : nay
      questions << qid if min_rebellion <= min.to_f / (max + min)      
    end
    questions
  end

  def self.find_questions_with_speeches(min_speeches)
    sql=<<-SQL
    select
      questions.id, count(speeches.id)
    from questions
      left join speeches on questions.id = question_id
    group by questions.id
    SQL
    collect_questions(sql, min_speeches)
  end
  
  def self.find_questions_with_attendances(min_attendances)
    sql=<<-SQL
    select 
    questions.id,
    sum(
      case present
        when true then 1
        when false then 0
      end
    ) as sp
    from questions, attendances, sittings
    where questions.sitting_id = sittings.id and attendances.sitting_id = sittings.id
    group by questions.id
    SQL
    collect_questions(sql, min_attendances)
  end

  
  def self.find_questions_with_votes(min_votes)
    questions = Array.new
    ParliamentVote.find(:all).each do |pv|
      votes = pv.action_yes + pv.action_no + pv.action_abstain
      novotes = pv.action_novote + pv.action_absent
      questions << pv.question_id if min_votes <= votes.to_f / (votes + novotes)
    end
    questions
  end
  
private 

  def self.collect_questions(sql, rule)
    questions = Array.new
    r = ActiveRecord::Base.connection.execute(sql)
    while row = r.fetch_row do
      questions << row[0].to_i if rule <= row[1].to_f
    end
    questions
  end
end
