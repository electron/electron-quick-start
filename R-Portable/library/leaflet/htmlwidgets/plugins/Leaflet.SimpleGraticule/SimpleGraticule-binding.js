  LeafletWidget.methods.addSimpleGraticule = function(interval, showOriginLabel,
  redraw, hidden, zoomIntervals, layerId, group) {
    (function() {
      this.layerManager.addLayer(
        L.simpleGraticule({
          interval: interval,
          showOriginLabel: showOriginLabel,
          redraw: redraw,
          hidden: hidden,
          zoomIntervals: zoomIntervals
        }),
        'shape', layerId, group);
    }).call(this);
  };
