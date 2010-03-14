require 'zeitgeist'
require 'io'
require 'iconv'

include Zeitgeist

$KCODE = 'u'
require 'jcode'

extractor = Zeitgeist::IO::OneFileLinesExtractor.new
wc = WordCounter.new(7,10)
ta = TextAnalyser.new(1..4,5..6, wc)
ignor = Array.new
File.new('ignor.txt').each_line{|l| ignor << l.chomp }
ta.ignore_database = ignor
Dir['2008stenogramos/in/*.txt'].each{|file|
  puts "-- " + file
  ta.analyse_text(extractor.extract(file, //))
  Zeitgeist::IO::FileOutput.new("2008stenogramos/out/#{File.basename(file, '.txt')}.csv").print( wc )
  Zeitgeist::IO::DivLeveledOutput.new("2008stenogramos/out/#{File.basename(file, '.txt')}.html").print( wc )
}