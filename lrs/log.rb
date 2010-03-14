require 'rubygems'
require 'log4r'

module Log
  @@lg = Log4r::Logger.new 'atviras-seimas'
  @@lg.outputters = Log4r::Outputter.stdout

  def log
    @@lg
  end
end