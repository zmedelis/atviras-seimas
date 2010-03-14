#!/usr/bin/env ruby
#RAILS_ENV = 'development'
#require File.dirname(__FILE__) + "/../config/environment"

require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'lrs/utils'
require 'jcode'
$KCODE = 'u'
require 'iconv'

include Utils

url = 'http://www3.lrs.lt/pls/inter/'
main_page = open('http://www3.lrs.lt/pls/inter/w5_vaizdas.home?p_kat=103483').read
doc = Hpricot(Iconv.new('utf-8', 'windows-1257').iconv(denormalize(main_page)))
img_url = (doc/"//a[@href ^= 'w5_vaizdas.nuotrauka' and position()]").first.attributes['href']

img_page = utf_page url+img_url, true
img = (img_page/"//img[@src *= 'ImageData']").first
f = File.new('papildomi_duomenys/dienos_nuotrauka.txt', 'w') 
f << img.attributes['src'] + "\n"
f << url+img_url + "\n"
f << img.attributes['alt'] + "\n"

