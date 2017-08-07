/**
 * Leaflet.MarkerCluster.Freezable sub-plugin for Leaflet.markercluster plugin.
 * Adds the ability to freeze clusters at a specified zoom.
 * Copyright (c) 2015 Boris Seang
 * Distributed under the MIT License (Expat type)
 */

// UMD
(function (root, factory) {
	if (typeof define === 'function' && define.amd) {
		// AMD. Register as an anonymous module.
		define(['leaflet'], function (L) {
			return (root.L.MarkerClusterGroup = factory(L));
		});
	} else if (typeof module === 'object' && module.exports) {
		// Node. Does not work with strict CommonJS, but
		// only CommonJS-like environments that support module.exports,
		// like Node.
		module.exports = factory(require('leaflet'));
	} else {
		// Browser globals
		root.L.MarkerClusterGroup = factory(root.L);
	}
}(this, function (L, undefined) { // Does not actually expect the 'undefined' argument, it is just a trick to have an undefined variable.

	var LMCG = L.MarkerClusterGroup,
	    LMCGproto = LMCG.prototype;

	LMCG.freezableVersion = '0.1.0';

	LMCG.include({

		_originalOnAdd: LMCGproto.onAdd,

		onAdd: function (map) {
			var frozenZoom = this._zoom;

			this._originalOnAdd(map);

			if (this._frozen) {

				// Restore the specified frozenZoom if necessary.
				if (frozenZoom >= 0 && frozenZoom !== this._zoom) {
					// Undo clusters and markers addition to this._featureGroup.
					this._featureGroup.clearLayers();

					this._zoom = frozenZoom;

					this.addLayers([]);
				}

				// Replace the callbacks on zoomend and moveend events.
				map.off('zoomend', this._zoomEnd, this);
				map.off('moveend', this._moveEnd, this);
				map.on('zoomend moveend', this._viewChangeEndNotClustering, this);
			}
		},

		_originalOnRemove: LMCGproto.onRemove,

		onRemove: function (map) {
			map.off('zoomend moveend', this._viewChangeEndNotClustering, this);
			this._originalOnRemove(map);
		},

		disableClustering: function () {
			return this.freezeAtZoom(this._maxZoom + 1);
		},

		disableClusteringKeepSpiderfy: function () {
			return this.freezeAtZoom(this._maxZoom);
		},

		enableClustering: function () {
			return this.unfreeze();
		},

		unfreeze: function () {
			return this.freezeAtZoom(false);
		},

		freezeAtZoom: function (frozenZoom) {
			this._processQueue();

			var map = this._map;

			// If frozenZoom is not specified, true or NaN, freeze at current zoom.
			// Note: NaN is the only value which is not eaqual to itself.
			if (frozenZoom === undefined || frozenZoom === true || (frozenZoom !== frozenZoom)) {
				// Set to -1 if not on map, as the sign to freeze as soon as it gets added to a map.
				frozenZoom = map ? Math.round(map.getZoom()) : -1;
			} else if (frozenZoom === 'max') {
				// If frozenZoom is "max", freeze at MCG maxZoom + 1 (eliminates all clusters).
				frozenZoom = this._maxZoom + 1;
			} else if (frozenZoom === 'maxKeepSpiderfy') {
				// If "maxKeepSpiderfy", freeze at MCG maxZoom (eliminates all clusters but bottom-most ones).
				frozenZoom = this._maxZoom;
			}

			var requestFreezing = typeof frozenZoom === 'number';

			if (this._frozen) { // Already frozen.
				if (!requestFreezing) { // Unfreeze.
					this._unfreeze();
					return this;
				}
				// Just change the frozen zoom: go straight to artificial zoom.
			} else if (requestFreezing) {
				// Start freezing
				this._initiateFreeze();
			} else { // Not frozen and not requesting freezing => nothing to do.
				return this;
			}

			this._artificialZoomSafe(this._zoom, frozenZoom);
			return this;
		},

		_initiateFreeze: function () {
			var map = this._map;

			// Start freezing
			this._frozen = true;

			if (map) {
				// Change behaviour on zoomEnd and moveEnd.
				map.off('zoomend', this._zoomEnd, this);
				map.off('moveend', this._moveEnd, this);

				map.on('zoomend moveend', this._viewChangeEndNotClustering, this);
			}
		},

		_unfreeze: function () {
			var map = this._map;

			this._frozen = false;

			if (map) {
				// Restore original behaviour on zoomEnd.
				map.off('zoomend moveend', this._viewChangeEndNotClustering, this);

				map.on('zoomend', this._zoomEnd, this);
				map.on('moveend', this._moveEnd, this);

				// Animate.
				this._executeAfterUnspiderfy(function () {
					this._zoomEnd(); // Will set this._zoom at the end.
				}, this);
			}
		},

		_executeAfterUnspiderfy: function (callback, context) {
			// Take care of spiderfied markers!
			// The cluster might be removed, whereas markers are on fake positions.
			if (this._unspiderfy && this._spiderfied) {
				this.once('animationend', function () {
					callback.call(context);
				});
				this._unspiderfy();
				return;
			}

			callback.call(context);
		},

		_artificialZoomSafe: function (previousZoom, targetZoom) {
			this._zoom = targetZoom;

			if (!this._map || previousZoom === targetZoom) {
				return;
			}

			this._executeAfterUnspiderfy(function () {
				this._artificialZoom(previousZoom, targetZoom);
			}, this);
		},

		_artificialZoom: function (previousZoom, targetZoom) {
			if (previousZoom < targetZoom) {
				// Make as if we had instantly zoomed in from previousZoom to targetZoom.
				this._animationStart();
				this._topClusterLevel._recursivelyRemoveChildrenFromMap(
					this._currentShownBounds, previousZoom, this._getExpandedVisibleBounds()
				);
				this._animationZoomIn(previousZoom, targetZoom);

			} else if (previousZoom > targetZoom) {
				// Make as if we had instantly zoomed out from previousZoom to targetZoom.
				this._animationStart();
				this._animationZoomOut(previousZoom, targetZoom);
			}
		},

		_viewChangeEndNotClustering: function () {
			var fg = this._featureGroup,
			    newBounds = this._getExpandedVisibleBounds(),
			    targetZoom = this._zoom;

			// Remove markers and bottom clusters outside newBounds, unless they come
			// from a spiderfied cluster.
			fg.eachLayer(function (layer) {
				if (!newBounds.contains(layer._latlng) && layer.__parent && layer.__parent._zoom < targetZoom) {
					fg.removeLayer(layer);
				}
			});

			// Add markers and bottom clusters in newBounds.
			this._topClusterLevel._recursively(newBounds, -1, targetZoom,
				function (c) { // Add markers from each cluster of lower zoom than targetZoom
					if (c._zoom === targetZoom) { // except targetZoom
						return;
					}

					var markers = c._markers,
					    i = 0,
					    marker;

					for (; i < markers.length; i++) {
						marker = c._markers[i];

						if (!newBounds.contains(marker._latlng)) {
							continue;
						}

						fg.addLayer(marker);
					}
				},
				function (c) { // Add clusters from targetZoom.
					c._addToMap();
				}
			);
		},

		_originalZoomOrSpiderfy: LMCGproto._zoomOrSpiderfy,

		_zoomOrSpiderfy: function (e) {
			if (this._frozen && this.options.spiderfyOnMaxZoom) {
				e.layer.spiderfy();
				if (e.originalEvent && e.originalEvent.keyCode === 13) {
					map._container.focus();
				}
			} else {
				this._originalZoomOrSpiderfy(e);
			}
		}

	});


	// Just return a value to define the module export.
	return LMCG;
}));
