class Sitting < ActiveRecord::Base
  has_many :questions, :dependent => :destroy
  has_many :votes, :through => :questions
  has_many :attendances, :dependent => :destroy
  belongs_to :session

  def approved_questions
    aq = Array.new
    questions.find(:all,:conditions=>{:stage=>'Priėmimas'}).each { |q|
      a = q.votes.count(:conditions => {:action => Vote::ABSTAIN})
      n = q.votes.count(:conditions => {:action => Vote::NO})
      y = q.votes.count(:conditions => {:action => Vote::YES})
      aq << q if y > n and y > a
    }
    aq
  end

end
