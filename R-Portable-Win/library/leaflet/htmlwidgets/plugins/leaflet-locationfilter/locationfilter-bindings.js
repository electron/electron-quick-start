/* global LeafletWidget, L, Shiny, HTMLWidgets, $ */

function getLocationFilterBounds(locationFilter) {
  if(locationFilter && locationFilter.getBounds) {
    var bounds = locationFilter.getBounds();
    var boundsJSON =
      {
        "sw_lat" : bounds.getSouth(),
        "sw_lng" : bounds.getWest(),
        "ne_lat" : bounds.getNorth(),
        "ne_lng" : bounds.getEast()
      };
    return boundsJSON;
  } else {
    return null;
  } 
}

LeafletWidget.methods.addLocationFilter = function(options) {
  (function() {
    var map = this;

    if(map.locationFilter) {
      map.locationFilter.remove();
      map.locationFilter = null;
    }

    if(!$.isEmptyObject(options.bounds)) {
      options.bounds = L.latLngBounds(options.bounds);
    }

    map.locationFilter = new L.LocationFilter(options);

    map.locationFilter.on("change", function(e) {
      if (!HTMLWidgets.shinyMode) return;
      Shiny.onInputChange(map.id+"_location_filter_changed",
        getLocationFilterBounds(map.locationFilter));
    });
    map.locationFilter.on("enabled", function(e) {
      if (!HTMLWidgets.shinyMode) return;
      Shiny.onInputChange(map.id+"_location_filter_enabled",
        getLocationFilterBounds(map.locationFilter));
    });
    map.locationFilter.on("disabled", function(e) {
      if (!HTMLWidgets.shinyMode) return;
      Shiny.onInputChange(map.id+"_location_filter_disabled",
        getLocationFilterBounds(map.locationFilter));
    });

    map.locationFilter.addTo(map);

  }).call(this);
};

LeafletWidget.methods.removeLocationFilter = function() {
  (function() {
    var map = this;

    if(map.locationFilter) {
      map.locationFilter.remove();
      map.locationFilter = null;
    }

  }).call(this);
};

