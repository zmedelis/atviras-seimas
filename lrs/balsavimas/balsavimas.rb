#!/usr/bin/env ruby
RAILS_ENV = 'development'
require File.dirname(__FILE__) + "/../../config/environment"

require 'app/models/sitting'
require 'app/models/question'
require 'app/models/vote'
require 'app/models/speech'
require 'app/models/political_group_vote'
require 'lrs/balsavimas/lrs_extractor'
require 'lrs/log'

include Log

#Session.delete_all
#Sitting.delete_all
#Question.delete_all
#Vote.delete_all
#Speech.delete_all
#Attendance.delete_all
#PoliticalGroupVote.delete_all
#ParliamentVote.delete_all
#DebateReference.delete_all

t = Time.now
(80..84).each{|x|
  sp = LrsExtractor.new "http://www3.lrs.lt/pls/inter/w5_sale.ses_pos?p_ses_id=#{x}"
  sp.sittings
}

log.info("Visiskai visas laikas: #{Time.now - t}")
#TODO butinai skirti balsavimus netik pagal laiko irasa bet ir pagal id
#TODO isaugoti klausimo id seime (sid)

log.info("***Panasumai***")
stats = Statistician.new
stats.vote_similarity
