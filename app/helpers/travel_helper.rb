module TravelHelper
  #wrap argumentas reikalingas kai kviecia is union_trips2html
  #nes union kitaip auksti pasiskaiciuoja
  def trips2html(state, wrap = true)
    trips = state.trips
    height = trips.size > 14 ? 330 : (trips.size * 20 + 80)
    cache = StateInfowindowHtmlCache.find_by_state_id(state.id)
    html = wrap ? "<div style='width:350px;height:" + height.to_s + "px;overflow:auto'>" : "" 
    html << cache.html
    html << "</div>" if wrap
    return html
  end
  
  def union_trips2html(union)
    html = "<div style='width:350px;height:330px;overflow:auto'>"
    union.states.each do |state|
      html << trips2html(state, false) if state.trips.size > 0
    end
    return html << "</div>"
  end
end
