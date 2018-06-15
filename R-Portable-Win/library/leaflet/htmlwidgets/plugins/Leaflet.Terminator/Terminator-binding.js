  LeafletWidget.methods.addTerminator = function(resolution, time,
  layerId, group, options) {
    (function() {
      this.layerManager.addLayer(
        L.terminator($.extend({
          resolution: resolution,
          time: time,
          group: group
        }, options || {})),
        'shape', layerId, group);
    }).call(this);
  };


