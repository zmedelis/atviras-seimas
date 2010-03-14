require 'app/models/political_group_vote'
require 'app/models/political_group'
require 'app/models/vote'
require 'app/models/vote_pattern'

class Statistician
  def political_group_votes(sitting)
    political_group_vote sitting
    parliament_vote sitting
    rebellion sitting
  end
  
  def vote_similarity
    VotePattern.delete_all
    full_time = Time.now
    Politician.find(:all).each do |mp1|
      t_all = Time.now
      Politician.find(:all).each do |mp2|
        unless mp1.id == mp2.id then
          t = Time.now
          done_already = mp2.vote_patterns.find(:first, :conditions => {:similar_voter_id => mp1.id})
          s = done_already.nil? ? sim_distance(mp1, mp2, mp1.votes.find(:all,:conditions=>["action != ?",Vote::ABSENT])) : done_already.score
          mp1.vote_patterns << mp1.vote_patterns.new(:similar_voter_id => mp2.id, :score => s) unless s.nan?
          printf "#{mp1.last_name} - #{mp2.last_name} (#{done_already.nil?}) laikas: #{Time.now - t}\n"
        end
      end
      printf "***** #{mp1.last_name} laikas: #{Time.now - t_all}\n"
    end
    printf "Visaslaikas: #{Time.now - full_time}\n"
  end

private

  def sim_distance(mp1, mp2, mp1_votes)
    match = 0
    count = 0
    mp1_votes.each do |v1|
      v2 = Vote.find(:first, :conditions => {:politician_id => mp2.id, :sid=>v1.sid})
      if v2 and v2.action != Vote::ABSENT then
        match += 1 if v1.action == v2.action
        count += 1
      end
    end
    match.to_f / count
  end
  
  def political_group_vote(sitting)
    sitting.questions.each do |question|
      sql_time = "select distinct time from votes where question_id = #{question.id}"
      r = ActiveRecord::Base.connection.execute(sql_time)
      while row = r.fetch_row do
        time = row[0]
        PoliticalGroup.find(:all).each do |pg|
          pgv = PoliticalGroupVote.new(:question_id => question.id, :political_group_id => pg.id)
          pgv.time = time
          pgv.action_absent = Vote.count(:all, :conditions => {:question_id => question.id, :political_group_id => pg.id, :time => time, :action => Vote::ABSTAIN})
          pgv.action_novote = Vote.count(:all, :conditions => {:question_id => question.id, :political_group_id => pg.id, :time => time, :action => Vote::NOVOTE})
          pgv.action_abstain = Vote.count(:all, :conditions => {:question_id => question.id, :political_group_id => pg.id, :time => time, :action => Vote::ABSTAIN})
          pgv.action_no = Vote.count(:all, :conditions => {:question_id => question.id, :political_group_id => pg.id, :time => time, :action => Vote::NO})
          pgv.action_yes = Vote.count(:all, :conditions => {:question_id => question.id, :political_group_id => pg.id, :time => time, :action => Vote::YES})
          pgv.save
        end
      end
  end

  def parliament_vote(sitting)
    sitting.questions.each do |question|
        pv = ParliamentVote.new(:question_id => question.id)
        pv.action_absent = PoliticalGroupVote.sum(:action_absent, :conditions => {:question_id => question.id})
        pv.action_novote = PoliticalGroupVote.sum(:action_novote, :conditions => {:question_id => question.id})
        pv.action_abstain = PoliticalGroupVote.sum(:action_abstain, :conditions => {:question_id => question.id})
        pv.action_no = PoliticalGroupVote.sum(:action_no, :conditions => {:question_id => question.id})
        pv.action_yes = PoliticalGroupVote.sum(:action_yes, :conditions => {:question_id => question.id})
        pv.save
      end
    end
  end

  def rebellion(sitting)
    #dabar paskaiciuojam maistus
    sitting.questions.each do |question|
      question.votes.find(:all, :conditions=>"(action = 4 OR action = 5)").each do |vote|
        pgv = PoliticalGroupVote.find(
          :first,
          :conditions => {:question_id => vote.question.id, :political_group_id => vote.political_group.id, :time => vote.time}
        )
        abstain = pgv.action_abstain
        yes = pgv.action_yes
        no = pgv.action_no
        if abstain < yes or abstain < no then
          vote.group_rebellion = vote.action == Vote::YES ? yes < no : yes > no
        else
          vote.group_rebellion = false
        end

        p_abstain = Vote.count(:all, :conditions => {:question_id => vote.question.id, :time => vote.time, :action => Vote::ABSTAIN})
        p_yes = Vote.count(:all, :conditions => {:question_id => vote.question.id, :time => vote.time, :action => Vote::YES})
        p_no = Vote.count(:all, :conditions => {:question_id => vote.question.id, :time => vote.time, :action => Vote::NO})
        if p_abstain < p_yes or p_abstain < p_no then
          vote.parliament_rebellion = vote.action == Vote::YES ? p_yes < p_no : p_yes > p_no
        else
          vote.parliament_rebellion = false
        end
        vote.save
      end
    end    
  end
end
