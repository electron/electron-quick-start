LeafletWidget.methods.addMiniMap =
  function(tilesURL, tilesProvider, position,
  width, height, collapsedWidth, collapsedHeight , zoomLevelOffset,
  zoomLevelFixed, centerFixed, zoomAnimation , toggleDisplay, autoToggleDisplay,
  minimized, aimingRectOptions, shadowRectOptions, strings, mapOptions) {

    (function() {
      if(this.minimap) {
        this.minimap.removeFrom( this );
      }

      // determin the tiles for the minimap
      // default to OSM tiles
      layer = new L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png');
      if(tilesProvider) {
        // use a custom tiles provider if specified.
        layer = new L.tileLayer.provider(tilesProvider);
      } else if(tilesURL) {
        // else use a custom tiles URL if specified.
        layer = new L.tileLayer(tilesURL);
      }

      this.minimap = new L.Control.MiniMap(layer, {
        position: position,
        width: width,
        height: height,
        collapsedWidth: collapsedWidth,
        collapsedHeight: collapsedWidth,
        zoomLevelOffset: zoomLevelOffset,
        zoomLevelFixed: zoomLevelFixed,
        centerFixed: centerFixed,
        zoomAnimation: zoomAnimation,
        toggleDisplay: toggleDisplay,
        autoToggleDisplay: autoToggleDisplay,
        minimized: minimized,
        aimingRectOptions: aimingRectOptions,
        shadowRectOptions: shadowRectOptions,
        strings: strings,
        mapOptions: mapOptions
      });
      this.minimap.addTo(this);
    }).call(this);
  };
