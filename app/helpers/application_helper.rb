# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def current_parliament
    "2008 - 2012"
  end

  def stat_percent( x, y )
    sprintf("%2.2f%", x.to_f / y.to_f * 100 )
  end

  def link_to_with_current(
    name, 
    options = {}, 
    html_options = {}, 
    *parameters_for_method_reference)
    
    html_options[:id] = "current" if current_page?(options)
    link_to(name, options, html_options, *parameters_for_method_reference)
  end

  def link_to_remote_with_current(
    name,
    options = {},
    html_options = {},
    *parameters_for_method_reference)
    
    html_options[:id] = "current" if current_page?(options)
    link_to_remote(name, options, html_options, *parameters_for_method_reference)
  end


end
