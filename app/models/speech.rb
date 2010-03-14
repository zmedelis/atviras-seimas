class Speech < ActiveRecord::Base
  belongs_to :question
  belongs_to :politician
end