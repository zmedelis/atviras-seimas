RAILS_ENV = 'development'
require File.dirname(__FILE__) + "/../../config/environment"

Mp.find(:all).each do |st|
	l = st.name_in_reports
	st.name_in_reports = Iconv.new('utf-8', 'windows-1257').iconv(l) 
	st.save
end
