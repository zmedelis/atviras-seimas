class DebateReference < ActiveRecord::Base
  #http://railsforum.com/viewtopic.php?id=16760
  belongs_to :politician
  belongs_to :name_reference, :class_name => 'Politician', :foreign_key => 'name_reference_id'
end
