require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'lrs/utils'
require 'lrs/balsavimas/sitting_builder'
require 'lrs/balsavimas/question_builder'
require 'lrs/balsavimas/debate_analyser'
require 'lrs/balsavimas/statistician'
require 'app/models/sitting'
require 'app/models/vote'
require 'lrs/log'

#
# Visas LRS HTML parsinimas (per hpricot) daromas cia.
# Po to atskiru elementu analize (dazniausiai su regexp) atliekama bilder klasese.
# T.y. atskiriama elementu gavimas is LRS ir po to sekantis ju panaudokimas atitinkamu
# duomenu objektu konstravimui
#
class LrsExtractor

  include Utils
  include Log

  @@LRS_PREFIX = 'http://www3.lrs.lt/pls/inter/'

  def initialize(session_id)
    @lrs_session = session_id
  end
  
  # surenkam visus sesijos posedziu url ir iskvieciam perduota bloka
  # kuris uziima posedzio analize
  def sittings
    t = Time.now
    @sitting_builder = SittingBuilder.new
    doc = utf_page @lrs_session, true
    #pirma surandam sesijos pavadinima
    s = (doc/"//h3").first.inner_text
    log.info('Sesija: ' + s)
    @sitting_builder.create_session s 
    @sitting_builder.session.save #TODO cia reikia patikrinti ar nera jau tokios sukurtos
    
    #dabar visi posedziai
    (doc/"//a").each do |sitting|
      if sitting.attributes['href'] =~ /p_fakt_pos_id=/ then #testui id=1028 po to ismest
        t_sit = Time.now
        log.info @@LRS_PREFIX + sitting.attributes['href']
        
        sitting_doc = utf_page(@@LRS_PREFIX + sitting.attributes['href'], true)
        sitting_title = sitting_doc.search( "//h3[text() ^= 'Seimo posėdis  Nr.']" ).inner_text
        @sitting_builder.create_sitting(sitting_title) if sitting_title != ''
        
        if @sitting_builder.sitting and sitting_title != '' then

          attendance_doc = utf_page(@@LRS_PREFIX + sitting.attributes['href'].gsub('.fakt_pos?','.lank_pos?'))
          attendance(attendance_doc)
          questions(sitting_doc)      
          @sitting_builder.sitting.questions << @question_builder.questions
          @sitting_builder.sitting.session = @sitting_builder.session
          begin
            Sitting.transaction do
              @sitting_builder.sitting.save!
              stats = Statistician.new
              stats.political_group_votes(@sitting_builder.sitting)
              stenogram = sitting_doc.search("//a[text() = 'Stenograma']").first
              #TODO dabar viskas ismetita puse stenogramu apdorojimo lab'e puse cia dar kita dalis isvis rankom
              #iskvieciama
              #cia tik issaugom stenogramos faila www_lrs dire
              if stenogram then
                utf_page stenogram.attributes['href']
                #DebateAnalyser.new( @sitting_builder.sitting ).analyse(stenogram_url)
              else
                log.warn("Stenogramos nėra #{sitting_title}\n")
              end
          end
          rescue
            printf "Posedis susisudino - #{@sitting_builder.sitting.sid}\n"
            print $!
          end
          log.info("Posedzio laikas: #{Time.now - t_sit}")
        else
          log.info("#{sitting_title} jau egzistuoja")
        end
      end
    end
    log.info("Visas laikas: #{Time.now - t}")

  end

  # Posedzio lankomumo parsinimas
  # doc - lankomumo dokumentas 
  # => pvz http://www3.lrs.lt/pls/inter/w5_sale.lank_pos?p_fakt_pos_id=1028
  def attendance(doc)
    (doc/"//a[@href *= 'p_asm_id=']").each do |mp|
      @sitting_builder.attendance(mp.attributes['href'], mp.parent.parent.children[0].inner_text.strip)
    end
  end

  # is posedzio protokolo surenkam visus klausimus kurie
  # buvo balsuojami, LRS psl jie zymimi [Priemimas]
  #
  # agenda - HPricot dokumentas su posedzio dienotvarke
  def questions(agenda)
    @question_builder = QuestionBuilder.new
    agenda.search("//td[@class='ltb']") do |formulation|
      log.info "\t#{@@LRS_PREFIX} #{formulation.search("/a").first.attributes['href']}"
      #sleep 2
      question = @question_builder.formulation formulation.inner_text
      url = formulation.search("/a").first.attributes['href']
      question.sid = url.match(/(p_svarst_kl_stad_id=)(-?\d+)/)[2]
      hearing( utf_page( @@LRS_PREFIX + url ) )
      question.votes << @question_builder.votes
      question.speeches << @question_builder.speeches
    end
  end

  # Klausimo svarstymo eiga. Pagrindinis psl: balsavimo, kalbu ir t.t. lentele
  #
  # protocol - HPricot dokumentas su svarstymu
  def hearing(protocol)
    protocol_table = protocol.search("//table[@class='basic']").first
    if protocol_table then
      #protocol_table.search("td:eq(1)") do |entry|
      protocol_table.search("tr") do |entry|
        time = entry.search("td:eq(0)").first.inner_text
        url_a = entry.search("td:eq(1)/a").first
        if url_a
          url = url_a.attributes['href']
          #einam i balsavimo puslapi, patikrinam ar url i balsavima. Jei url turi p_bals_id
          #tada cia balsavimas, gali buti ir p_asm_id - tai kalbejes del klausimo, p_reg_id
          #registracijos psl
          voting(utf_page(@@LRS_PREFIX + url), time, url.match(/(p_bals_id=)(-?\d+)/)[2]) if url.include? 'p_bals_id'
          #registruojam kalbas
          @question_builder.speech(url, time) if url.include? 'p_asm_id'
        end
      end
    end
  end

  # Balsavimo rezultatai. Puslapio su balsavimo rezultatais parsinimas
  #
  # rollcall - HPricot dokumentas su balsavimo rezultatais
  def voting(rollcall, time, lrs_id)
    rollcall.search('/html/body/div/table/tr[3]/td/table/tr/td/div[4]/table/tr').each do |vote|
      if vote.search('th').size == 0 then
        @question_builder.vote_record(
          @sitting_builder.sitting,
          vote.search('td/a').first.attributes['href'],  #perduodam seimo nario URL is jo gausim ID 
          vote.search('td:eq(1)').inner_text, 
          vote.search('td:eq(2)').inner_text, 
          vote.search('td:eq(3)').inner_text, 
          vote.search('td:eq(4)').inner_text,
          time,
          lrs_id
        )
      end
    end
  end
end
