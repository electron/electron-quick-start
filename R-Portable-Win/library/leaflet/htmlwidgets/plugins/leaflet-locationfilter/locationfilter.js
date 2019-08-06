/* eslint indent: "off", quotes: "off" */
/* global L */
/*
 * Leaflet.locationfilter - leaflet location filter plugin
 * Copyright (C) 2012, Tripbirds.com
 * http://tripbirds.com
 *
 * Licensed under the MIT License.
 *
 * Date: 2012-09-24
 * Version: 0.1
 */
L.LatLngBounds.prototype.modify = function(map, amount) {
    var sw = this.getSouthWest(),
        ne = this.getNorthEast(),
        swPoint = map.latLngToLayerPoint(sw),
        nePoint = map.latLngToLayerPoint(ne);

    sw = map.layerPointToLatLng(new L.Point(swPoint.x-amount, swPoint.y+amount));
    ne = map.layerPointToLatLng(new L.Point(nePoint.x+amount, nePoint.y-amount));

    return new L.LatLngBounds(sw, ne);
};

L.LocationFilter2 = L.Layer.extend({
    includes: L.Mixin.Events,

    options: {
    },

    initialize: function(options) {
        L.Util.setOptions(this, options);
    },

    addTo: function(map) {
        map.addLayer(this);
        return this;
    },

    onAdd: function(map) {
        this._map = map;
        this.enable();
    },

    onRemove: function(map) {
        this.disable();
    },

    /* Get the current filter bounds */
    getBounds: function() {
        return new L.LatLngBounds(this._sw, this._ne);
    },

    setBounds: function(bounds) {
        this._nw = bounds.getNorthWest();
        this._ne = bounds.getNorthEast();
        this._sw = bounds.getSouthWest();
        this._se = bounds.getSouthEast();
        if (this.isEnabled()) {
            this._draw();
            this.fire("change", {bounds: bounds});
        }
    },

    isEnabled: function() {
        return this._enabled;
    },

    /* Draw a rectangle */
    _drawRectangle: function(bounds, options) {
        options = options || {};
        var defaultOptions = {
            stroke: false,
            fill: true,
            fillColor: "black",
            fillOpacity: 0.3,
            clickable: false
        };
        options = L.Util.extend(defaultOptions, options);
        var rect = new L.Rectangle(bounds, options);
        rect.addTo(this._layer);
        return rect;
    },

    /* Draw a draggable marker */
    _drawImageMarker: function(point, options) {
        var marker = new L.Marker(point, {
            icon: new L.DivIcon({
                iconAnchor: options.anchor,
                iconSize: options.size,
                className: options.className
            }),
            draggable: true
        });
        marker.addTo(this._layer);
        return marker;
    },

    /* Draw a move marker. Sets up drag listener that updates the
       filter corners and redraws the filter when the move marker is
       moved */
    _drawMoveMarker: function(point) {
        var that = this;
        this._moveMarker = this._drawImageMarker(point, {
            "className": "location-filter move-marker",
            "anchor": [-10, -10],
            "size": [13,13]
        });
        function shiftByPixels(map, latlng, xy) {
            var orig = map.latLngToLayerPoint(latlng);
            return map.layerPointToLatLng(L.point(
                orig.x + xy.x,
                orig.y + xy.y
            ));
        }
        function constrainDelta(map, latlng, xy) {
            var orig = map.latLngToLayerPoint(latlng);
            var shifted = shiftByPixels(map, latlng, xy);
            var ending = map.latLngToLayerPoint(shifted);
            return L.point(ending.x - orig.x, ending.y - orig.y);
        }
        this._moveMarker.on('drag', function(e) {
            var markerPos = that._map.latLngToLayerPoint(that._moveMarker.getLatLng()),
                startPos = that._map.latLngToLayerPoint(that._nw),
                delta = L.point(markerPos.x - startPos.x, markerPos.y - startPos.y);

            // Prevent dragging off the map.
            delta = constrainDelta(that._map, that._nw, delta);
            delta = constrainDelta(that._map, that._ne, delta);
            delta = constrainDelta(that._map, that._sw, delta);
            delta = constrainDelta(that._map, that._se, delta);

            // Move all of the points.
            that._nw = shiftByPixels(that._map, that._nw, delta);
            that._ne = shiftByPixels(that._map, that._ne, delta);
            that._sw = shiftByPixels(that._map, that._sw, delta);
            that._se = shiftByPixels(that._map, that._se, delta);

            that._draw();
        });
        this._setupDragendListener(this._moveMarker);
        return this._moveMarker;
    },

    /* Draw a resize marker */
    _drawResizeMarker: function(point, orientation) {
        return this._drawImageMarker(point, {
            "className": "location-filter resize-marker " + orientation,
            "anchor": [7, 6],
            "size": [13, 12]
        });
    },

    /* Track moving of the given resize marker and update the markers
       given in options.moveAlong to match the position of the moved
       marker. Update filter corners and redraw the filter */
    _setupResizeMarkerTracking: function(marker, options) {
        var that = this;
        marker.on('drag', function(e) {
            var curPosition = marker.getLatLng(),
                latMarker = options.moveAlong.lat,
                lngMarker = options.moveAlong.lng;
            // Keep the marker inside the map
            marker.setLatLng(curPosition);
            // Move follower markers when this marker is moved
            latMarker.setLatLng(new L.LatLng(curPosition.lat, latMarker.getLatLng().lng, true));
            lngMarker.setLatLng(new L.LatLng(lngMarker.getLatLng().lat, curPosition.lng, true));
            // Sort marker positions in nw, ne, sw, se order
            var corners = [that._nwMarker.getLatLng(),
                           that._neMarker.getLatLng(),
                           that._swMarker.getLatLng(),
                           that._seMarker.getLatLng()];
            corners.sort(function(a, b) {
                if (a.lat != b.lat)
                    return b.lat-a.lat;
                else
                    return a.lng-b.lng;
            });
            // Update corner points and redraw everything except the resize markers
            that._nw = corners[0];
            that._ne = corners[1];
            that._sw = corners[2];
            that._se = corners[3];
            that._draw({repositionResizeMarkers: false});
        });
        this._setupDragendListener(marker);
    },

    /* Emit a change event whenever dragend is triggered on the
       given marker */
    _setupDragendListener: function(marker) {
        var that = this;
        marker.on('dragend', function(e) {
            that.fire("change", {bounds: that.getBounds()});
        });
    },

    /* Create bounds for the mask rectangles and the location
       filter rectangle */
    _calculateBounds: function() {
        var mapBounds = this._map.getBounds(),
            outerBounds = new L.LatLngBounds(
                new L.LatLng(mapBounds.getSouthWest().lat-0.1,
                             mapBounds.getSouthWest().lng-0.1, true),
                new L.LatLng(mapBounds.getNorthEast().lat+0.1,
                             mapBounds.getNorthEast().lng+0.1, true)
            );

        // The south west and north east points of the mask */
        this._osw = outerBounds.getSouthWest();
        this._one = outerBounds.getNorthEast();

        // Bounds for the mask rectangles
        this._northBounds = new L.LatLngBounds(new L.LatLng(this._ne.lat, this._osw.lng, true), this._one);
        this._westBounds = new L.LatLngBounds(new L.LatLng(this._sw.lat, this._osw.lng, true), this._nw);
        this._eastBounds = new L.LatLngBounds(this._se, new L.LatLng(this._ne.lat, this._one.lng, true));
        this._southBounds = new L.LatLngBounds(this._osw, new L.LatLng(this._sw.lat, this._one.lng, true));
    },

    /* Initializes rectangles and markers */
    _initialDraw: function() {
        if (this._initialDrawCalled) {
            return;
        }

        this._layer = new L.LayerGroup();

        // Calculate filter bounds
        this._calculateBounds();

        // Create rectangles
        this._northRect = this._drawRectangle(this._northBounds);
        this._westRect = this._drawRectangle(this._westBounds);
        this._eastRect = this._drawRectangle(this._eastBounds);
        this._southRect = this._drawRectangle(this._southBounds);
        this._innerRect = this._drawRectangle(this.getBounds(), {
            fillOpacity: 0,
            stroke: true,
            color: "white",
            weight: 1,
            opacity: 0.9
        });

        // Create resize markers
        this._nwMarker = this._drawResizeMarker(this._nw, "nwse");
        this._neMarker = this._drawResizeMarker(this._ne, "nesw");
        this._swMarker = this._drawResizeMarker(this._sw, "nesw");
        this._seMarker = this._drawResizeMarker(this._se, "nwse");

        // Setup tracking of resize markers. Each marker has pair of
        // follower markers that must be moved whenever the marker is
        // moved. For example, whenever the north west resize marker
        // moves, the south west marker must move along on the x-axis
        // and the north east marker must move on the y axis
        this._setupResizeMarkerTracking(this._nwMarker, {moveAlong: {lat: this._neMarker, lng: this._swMarker}});
        this._setupResizeMarkerTracking(this._neMarker, {moveAlong: {lat: this._nwMarker, lng: this._seMarker}});
        this._setupResizeMarkerTracking(this._swMarker, {moveAlong: {lat: this._seMarker, lng: this._nwMarker}});
        this._setupResizeMarkerTracking(this._seMarker, {moveAlong: {lat: this._swMarker, lng: this._neMarker}});

        // Create move marker
        this._moveMarker = this._drawMoveMarker(this._nw);

        this._initialDrawCalled = true;
    },

    /* Reposition all rectangles and markers to the current filter bounds. */
    _draw: function(options) {
        options = L.Util.extend({repositionResizeMarkers: true}, options);

        // Calculate filter bounds
        this._calculateBounds();

        // Reposition rectangles
        this._northRect.setBounds(this._northBounds);
        this._westRect.setBounds(this._westBounds);
        this._eastRect.setBounds(this._eastBounds);
        this._southRect.setBounds(this._southBounds);
        this._innerRect.setBounds(this.getBounds());

        // Reposition resize markers
        if (options.repositionResizeMarkers) {
            this._nwMarker.setLatLng(this._nw);
            this._neMarker.setLatLng(this._ne);
            this._swMarker.setLatLng(this._sw);
            this._seMarker.setLatLng(this._se);
        }

        // Reposition the move marker
        this._moveMarker.setLatLng(this._nw);
    },

    /* Adjust the location filter to the current map bounds */
    _adjustToMap: function() {
        this.setBounds(this._map.getBounds());
        this._map.zoomOut();
    },

    /* Enable the location filter */
    enable: function() {
        if (this._enabled) {
            return;
        }

        // Initialize corners
        var bounds;
        if (this._sw && this._ne) {
            bounds = new L.LatLngBounds(this._sw, this._ne);
        } else if (this.options.bounds) {
            bounds = this.options.bounds;
        } else {
            var mapBounds = this._map.getBounds();
            var mapnw = this._map.latLngToLayerPoint(mapBounds.getNorthWest());
            var mapse = this._map.latLngToLayerPoint(mapBounds.getSouthEast());

            bounds = new L.LatLngBounds(
                this._map.layerPointToLatLng(L.point((mapnw.x*1.5 + mapse.x*0.5)/2, (mapnw.y*1.5 + mapse.y*0.5)/2)),
                this._map.layerPointToLatLng(L.point((mapnw.x*0.5 + mapse.x*1.5)/2, (mapnw.y*0.5 + mapse.y*1.5)/2))
            );
        }
        this._map.invalidateSize();
        this._nw = bounds.getNorthWest();
        this._ne = bounds.getNorthEast();
        this._sw = bounds.getSouthWest();
        this._se = bounds.getSouthEast();

        // Draw filter
        this._initialDraw();
        this._draw();

        // Set up map move event listener
        var that = this;
        this._moveHandler = function() {
            that._draw();
        };
        this._map.on("move", this._moveHandler);

        // Add the filter layer to the map
        this._layer.addTo(this._map);

        // Zoom out the map if necessary
        var mapBounds = this._map.getBounds();
        bounds = new L.LatLngBounds(this._sw, this._ne).modify(this._map, 10);
        if (!mapBounds.contains(bounds.getSouthWest()) || !mapBounds.contains(bounds.getNorthEast())) {
            this._map.fitBounds(bounds);
        }

        this._enabled = true;

        // Fire the enabled event
        this.fire("enabled");
    },

    /* Disable the location filter */
    disable: function() {
        if (!this._enabled) {
            return;
        }

        // Remove event listener
        this._map.off("move", this._moveHandler);

        // Remove rectangle layer from map
        this._map.removeLayer(this._layer);

        this._enabled = false;

        // Fire the disabled event
        this.fire("disabled");
    }
});
