require 'rubygems'
require 'active_record'

require 'app/models/question'
require 'app/models/political_group'
require 'lrs/log'

#
# Klausimo duomenu klases konstravimas. Cia jau nebeatliekama html parsinimas, bet gali 
# buti atliekama tolesne duomenu analize su RegExp
# 
#     http://www3.lrs.lt/pls/inter/w5_sale.klaus_stadija?p_svarst_kl_stad_id=16548
#     http://www3.lrs.lt/pls/inter/w5_sale.bals?p_bals_id=15157
#
class QuestionBuilder
  attr_reader :questions, :votes, :speeches
  
  include Log
  
  def initialize()
    @questions = Array.new
  end

  # Klausimo tipas
  #   pvz: Seimo STATUTO "Dėl Seimo statuto 32 straipsnio pakeitimo" PROJEKTAS (Nr. XP-275)  [Pateikimas] 
  # sio klausimo tipas yra Pateikimas
  # si parsinima reiktu atlikti pacio klausimo puslapije o ne posedzio, taciau ten ji labai sunku isekstraktinti
  def formulation(text)
    @votes = Array.new      #naujas klausimas naujas balsavimo masyvas, bus pildomas per vote_record
    @speeches = Array.new   #tas pat jas su votes
    q = text.strip.gsub(/\n/, '')
    
    qtype_re = q.match(/\[(\w+)\]/)
    if qtype_re     #kartais klausimas buna be stadijos ([svarstoma]), 
      #taip dazniausiai buna proceduriniuose balsavimuose
      qtype = qtype_re[1]
      qformulation = q.gsub(qtype_re[0],'')
    else
      qtype = ''
      qformulation = q.strip 
    end
    question = Question.new
    question.formulation = qformulation.strip
    question.stage = qtype
    @questions << question
    return question     #grazinam klausimo objekta kuris poto bus naudojamas vote_record surisimui
  end
  
  # Balsavimo rezultatai
  # @mp - balsaves seimo narys
  # @party
  # @ffor
  # @against
  # @abstain
  def vote_record(sitting, mp, party, ffor, against, abstain, time, lrs_id)
    p = Politician.find_by_id_in_lrs mp.match(/(p_asm_id=)(\d+)/)[2]
    vote = Vote.new  	
    vote.politician_id = p.id

		party_code = party.strip != '' ? party.strip : 'MG'
		log.warn "Partija #{party.strip} nerasta! Politikui #{p.full_name} duodam MG" unless party.strip != ''
    pg = PoliticalGroup.find_by_code(party_code)
    vote.political_group_id = pg.id
    
    
    vote.action = Vote::ABSENT                     #1 jei nedalyvavo
    sitting.attendances.each{                     #2 jei nebalsavo
      |a| vote.action = Vote::NOVOTE if a.politician == p and a.present
    }
    vote.action = Vote::ABSTAIN if abstain.strip == '+' #3 jei SUSILAIKE
    vote.action = Vote::NO if against.strip == '+'      #5 jei NE
    vote.action = Vote::YES if ffor.strip == '+'        #4 jei TAIP
    
    vote.time = time
    vote.sid = lrs_id
    @votes << vote
  end
	
  def speech(speaker, time)
    p = Politician.find_by_id_in_lrs speaker.match(/(p_asm_id=)(\d+)/)[2]
    s = Speech.new
    s.politician_id = p.id
    s.time = time
    @speeches << s
  end
end
