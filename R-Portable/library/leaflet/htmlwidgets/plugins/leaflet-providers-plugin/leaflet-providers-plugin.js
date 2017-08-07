LeafletWidget.methods.addProviderTiles = function(provider, layerId, group, options) {
  this.layerManager.addLayer(L.tileLayer.provider(provider, options), "tile", layerId, group);
};
