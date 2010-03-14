class PoliticalGroupVote < ActiveRecord::Base
  belongs_to :question
  belongs_to :political_group
end
