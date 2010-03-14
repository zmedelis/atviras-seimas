var mgr;
var map;

var trips_in_state_service = "/data_service/trips_in_state?iso=";
var trips_by_mp_service = "/data_service/trips_by_mp?sn=";

function load() {
    startProgress();
    map = new GMap2(document.getElementById("map"));
    map.addControl(new GSmallMapControl());
    centerWorld();
    mgr = new MarkerManager(map);
    
    GDownloadUrl("/data_service/trips", function(data) {
        var xml = GXml.parse(data);
        add_trips(xml.documentElement.childNodes, trips_in_state_service, "iso", 0, 17);
        endProgress();
        
    });	
    mgr.refresh();
}

function load_mp(mp){
    startProgress();
    mgr.clearMarkers();
    GDownloadUrl(trips_by_mp_service + mp, function(data) {
        var xml = GXml.parse(data);
        add_trips(xml.documentElement.childNodes, trips_by_mp_service, "sn_id", 0, 17);
        endProgress();
    });
    mgr.refresh();
}

//rekursine funkcija
//kiekvienai rastai grupei(ES) rekusriskai iskvienciama kad prideti grupes salis
function add_trips(nodes, service, query, zoom_min, zoom_max) {
    for (var i=0;i<nodes.length;i++)
        {
            var destination = nodes[i];
            if (destination.nodeType == 1){
                var type = destination.localName;
                var q = destination.getElementsByTagName(query)[0].childNodes[0].nodeValue;
                var lng = destination.getElementsByTagName("lng")[0].childNodes[0].nodeValue;
                var lat = destination.getElementsByTagName("lat")[0].childNodes[0].nodeValue;
                var count = destination.getElementsByTagName("komandiruociu_kiekis")[0].childNodes[0].nodeValue;
                
                if( destination.localName == "grupe" ){
                    mgr.addMarker(createMarker( "grupe", q, lng, lat, count, service), 0, 2);
                    add_trips(destination.getElementsByTagName("salis"), service, query, 3, 17);
                }
                else{
                    mgr.addMarker(createMarker( "salis", q, lng, lat, count, service), zoom_min, zoom_max);
                }
            }
        }
    }
    
    
    // Pridedamas marekeris. Info lango HTML in irfo uzklausimas padaromi ant
    // event, taip nesiunciama daug duomenu
    function createMarker(type, destination, lng, lat, label, service) {
        var latlng = new GLatLng(lat, lng);
        var icon = new GIcon();
        icon.image = '/images/' + type + '.png';
        icon.iconSize = new GSize(9 * label.length + 1, 15);
        icon.iconAnchor = new GPoint(10, 10);
        icon.infoWindowAnchor = new GPoint(0, 0);
        
        opts = {
            "icon": icon,
            "clickable": true,
            "labelText": label,
            "labelOffset": new GSize(-9, -10)
        };
        var marker = new LabeledMarker(latlng, opts);
        GEvent.addListener(marker, "click", function() {
            startProgress();
            GDownloadUrl(service + destination, function(data) {
                marker.openInfoWindowHtml(trip_info_to_html(GXml.parse(data)));
            });
            endProgress();
        });
        return marker;
    }
    
    function trip_info_to_html(xml){
        var size = 0;
        var html = "";
        var state;
        var nodes = xml.getElementsByTagName("salis");
        for (var i=0;i<nodes.length;i++){
            var state = nodes[i];
            var name = state.getElementsByTagName("pavadinimas")[0].childNodes[0].nodeValue;
            html += "<p class='blockname'>" + name + "</p>";
            html += "<table class='smalltable'><tr><th style='font-style:italic'>Seimo narys</th><th style='font-style:italic'>Nuo</th><th style='font-style:italic'>Iki</th></tr>";
            var tripNodes = state.getElementsByTagName("komandiruote");
            var trip;
            for (var j=0;j<tripNodes.length;j++){
                trip = tripNodes[j];
                html += "<tr><td>" + 
                trip.getElementsByTagName("seimo_narys")[0].childNodes[0].nodeValue + 
                "</td>" +
                "<td>" +
                trip.getElementsByTagName("data_nuo")[0].childNodes[0].nodeValue +
                "</td>" +
                "<td>" +
                trip.getElementsByTagName("data_iki")[0].childNodes[0].nodeValue +
                "</td></tr>";
                size++;
            }
            html += "</table>";
        }
        
        var height = size > 5 ? 140 : (size * 10 + 80);
        html = "<div style='width:300px;height:" + height + "px;overflow:auto'>" + 
        html +
        "</div>";	
        return html;
    }
    
    // zoominimo funkcijos
    function centerNA(){map.setCenter(new GLatLng(37.5,-98.0),3);}
    function centerEU(){map.setCenter(new GLatLng(55.0,18.0),3);}
    function centerWorld(){map.setCenter(new GLatLng(25.0,35.0),2);}
    
    window.onunload = GUnload;