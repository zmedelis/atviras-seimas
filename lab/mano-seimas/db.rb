require 'rexml/document'

include REXML


class DB
  def initialize
    @political_groups = Document.new File.new('xml/frakcijos.xml')
    @parties = Document.new File.new('xml/partijos.xml')
    @committees = Document.new File.new('xml/komitetai.xml')
    @ministries = Document.new File.new('xml/ministerijos.xml')
    @project_themes = Document.new File.new('xml/balsavimu-temos.xml')
  end

  def ministry_by_name(name)
    get_id(@ministries, "/lrs/ministerija[@pavadinimas = '#{name}']")
  end

  def committee_by_name(name)
    get_id(@committees, "/lrs/komitetas[@pavadinimas = '#{name}']")
  end

  def political_group_by_name(name)
    get_id(@political_groups, "/lrs/frakcija[@pavadinimas = '#{name}']")
  end
  def party_by_short_name(name)
    get_id(@parties, "/lrs/partija[@trumpas = '#{name}']")
  end
  
  def theme_id(name)
    get_id(@project_themes, "/lrs/balasavimo_tema[@pavadinimas = '#{name}']")
  end

  private
  
  def get_id(doc, xpath)
    v = XPath.first(doc, xpath)
    v.nil? ? -1 : v.attributes['id']
  end
end