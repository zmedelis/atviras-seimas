class PoliticalGroup < ActiveRecord::Base
  has_many :politicians
  has_many :political_group_votes
end
