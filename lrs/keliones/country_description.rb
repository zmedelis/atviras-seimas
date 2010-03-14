#valstybiu kodu mapas 
#viskas surasyta valstybes.txt faile
class CountryDescription
  def initialize
    @state_codes = Hash.new
     File.new('scraping/valstybes.txt', 'r').each_line{|line|
      state, code, iso_code, full_name  = line.split(',')
      @state_codes[full_name.chomp] = iso_code
     }
  end
  def state_code( full_name )
    @state_codes[full_name]
  end
end