class Session < ActiveRecord::Base
  has_many :sittings, :dependent => :destroy
end
