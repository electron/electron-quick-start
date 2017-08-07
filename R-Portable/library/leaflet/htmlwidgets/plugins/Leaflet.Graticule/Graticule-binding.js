  LeafletWidget.methods.addGraticule = function(interval, sphere, style,
  layerId, group, options) {
    (function() {
      this.layerManager.addLayer(
        L.graticule($.extend({
          interval: interval,
          sphere: sphere,
          style: style
        }, options || {})),
        'shape', layerId, group);
    }).call(this);
  };
