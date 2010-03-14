require 'rubygems'
require 'active_record'
require 'lrs/log'

require 'app/models/sitting'

#
# Klase konstruoja Posedzio model
#
class SittingBuilder
  include Log
  attr_reader :sitting
  attr_reader :session

  # suskuriam sesija, kuriai posedis priklauso
  # => 8 eilinė Seimo sesija (2008-03-10 - ...)
  def create_session(text)
    md = text.match /(.+)\((\d{4}-\d{2}-\d{2}) - (\d{4}-\d{2}-\d{2}|\.\.\.)\)/
    @session = Session.find_or_create_by_name(md[1].strip)
    @session.from = Date.strptime(md[2], '%Y-%m-%d')
    @session.to = Date.strptime(md[3], '%Y-%m-%d') if md[3] != '...'
  end

  # Parsinam posedzio pavadinima
  #   pvz: Seimo posėdis Nr.26 (2005-02-15, rytinis)
  def create_sitting(text)
    @sitting = nil
    no = text.match(/Nr\.(\d+)/)[1]
    date = text.match(/\d{4}-\d{2}-\d{2}/)[0]
    name = text.match(/-\d{2}, (.+)\)/)[1] 
    
    @sitting = Sitting.new(:name => name, :sid => no, :date => Date.strptime(date, '%Y-%m-%d')) unless Sitting.find_by_sid(no)
  end
  
  #mp - url seimo puslapije
  #presence - + jei dalivavo
  def attendance(mp, presence)
    p = Politician.find_by_id_in_lrs mp.match(/(p_asm_id=)(\d+)/)[2]
    if p then
      a = Attendance.new
      a.politician_id = p.id
      a.present = presence == '+'
      @sitting.attendances << a
    else
      log.warn("Lankomumas. Politikas #{mp.match(/(p_asm_id=)(\d+)/)[2]} nerastas")
    end
  end
end
