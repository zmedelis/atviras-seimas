ActionController::Routing::Routes.draw do |map|
  map.connect '', :controller => 'kpi', :action => 'index'
  map.connect 'komandiruotes', :controller => 'travel', :action => 'index'
  map.connect 'xml', :controller => 'data_service'
  map.connect 'xml/seimo_nariai', :controller => 'data_service', :action=>'lrs_mps'
  map.connect 'xml/komandiruotes', :controller => 'data_service', :action=>'trips'
  map.connect 'xml/komandiruotes_salis/:iso', :controller => 'data_service', :action=>'trips_in_state'
  map.connect 'xml/komandiruotes_seimas/:sn', :controller => 'data_service', :action=>'trips_by_mp'
  map.connect 'seimo_nariai', :controller => 'politicians', :action => 'index'
  map.connect 'seimo_nariai.:format', :controller => 'politicians', :action => 'index'
  map.connect 'seimo_nariai/politikas/:id', :controller => 'politicians', :action => 'show'
  map.connect 'seimo_nariai/politikas/:id.:format', :controller => 'politicians', :action => 'show'
  map.connect 'klausimai', :controller => 'questions', :action => 'index'
  map.connect 'klausimai/balsavimas/:id', :controller => 'questions', :action => 'show'
  map.connect 'klausimai/balsavimas/:id.:format', :controller => 'questions', :action => 'show'
  

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action.:format'
  map.connect ':controller/:action/:id.:format'
end