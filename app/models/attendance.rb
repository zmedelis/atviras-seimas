class Attendance < ActiveRecord::Base
  belongs_to :sitting
  belongs_to :politician
end
