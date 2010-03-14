class VotePattern < ActiveRecord::Base
  belongs_to :politician
  belongs_to :similar_voter, :class_name => 'Politician', :foreign_key => 'similar_voter_id'
end
