module DataServiceHelper
  def state_to_xml(xml, state)
    xml.salis do
      state_info(xml, state)
    end
  end

  # mp != nil kai iskvieciamas trip_by_mp
  def trip_to_xml(xml, state, mp=nil)
    xml.salis do
      xml.sn_id @mp.id_in_lrs if mp
      state_info(xml, state)
      for trip in state.trips
        xml.komandiruote do
          xml.seimo_narys(trip.politician.full_name)
          xml.data_nuo(trip.start_date.to_s)
          xml.data_iki(trip.end_date.to_s)
        end
      end
    end
  end

  private
  def state_info(xml, state)
    xml.iso(state.iso_id)
    xml.lng(state.lng)
    xml.lat(state.lat)
    xml.pavadinimas(state.state_labels[0].label)
    xml.komandiruociu_kiekis(state.trips.size)
  end
end
