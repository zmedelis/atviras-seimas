class Trip < ActiveRecord::Base
  belongs_to :state
  belongs_to :politician
end