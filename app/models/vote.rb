class Vote < ActiveRecord::Base
  
  include PoliticiansHelper
  
  belongs_to :question
  belongs_to :political_group
  belongs_to :politician
  
  validates_presence_of :political_group

  ABSENT = 1
  NOVOTE = 2
  ABSTAIN = 3
  NO = 4
  YES = 5
end