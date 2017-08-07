/*
 Leaflet.AwesomeMarkers, a plugin that adds colorful iconic markers for Leaflet, based on the Font Awesome icons
 (c) 2012-2013, Lennard Voogdt

 http://leafletjs.com
 https://github.com/lvoogdt
 */

/*global L*/

(function (window, document, undefined) {
    "use strict";
    /*
     * Leaflet.AwesomeMarkers assumes that you have already included the Leaflet library.
     */

    L.AwesomeMarkers = {};

    L.AwesomeMarkers.version = '2.0.1';

    L.AwesomeMarkers.Icon = L.Icon.extend({
        options: {
            iconSize: [35, 45],
            iconAnchor:   [17, 42],
            popupAnchor: [1, -32],
            shadowAnchor: [10, 12],
            shadowSize: [36, 16],
            className: 'awesome-marker',
            prefix: 'glyphicon',
            spinClass: 'fa-spin',
            extraClasses: '',
            icon: 'home',
            markerColor: 'blue',
            iconColor: 'white',
            iconRotate: 0,
            font: 'monospace'
        },

        initialize: function (options) {
            options = L.Util.setOptions(this, options);
        },

        createIcon: function () {
            var div = document.createElement('div'),
                options = this.options;

            if (options.icon) {
                div.innerHTML = this._createInner();
            }

            if (options.bgPos) {
                div.style.backgroundPosition =
                    (-options.bgPos.x) + 'px ' + (-options.bgPos.y) + 'px';
            }

            this._setIconStyles(div, 'icon-' + options.markerColor);
            return div;
        },

        _createInner: function() {
            var iconClass,
                iconSpinClass = "",
                iconColorClass = "",
                iconColorStyle = "",
                options = this.options;

            if(!options.prefix || (options.icon.slice(0,options.prefix.length+1) === options.prefix + "-")) {
                iconClass = options.icon;
            } else {
                iconClass = options.prefix + "-" + options.icon;
            }

            if(options.spin && typeof options.spinClass === "string") {
                iconSpinClass = options.spinClass;
            }

            if(options.iconColor) {
                if ((options.iconColor === 'white' || options.iconColor === 'black') &&
                    options.prefix !== 'fa') {
                    iconColorClass = "icon-" + options.iconColor;
                } else if (options.prefix === 'fa' && options.iconColor === 'white') {
                  iconColorClass = "fa-inverse";
                } else {
                    iconColorStyle = "color: " + options.iconColor + ";";
                }
            }
            if(options.font && options.text) {
                iconColorStyle += "font-family: " + options.font + ";";
            }

            if(options.iconRotate && options.iconRotate !== 0) {
                iconColorStyle += "-webkit-transform: rotate(" + options.iconRotate + "deg);";
                iconColorStyle += "-moz-transform: rotate(" + options.iconRotate + "deg);";
                iconColorStyle += "-o-transform: rotate(" + options.iconRotate + "deg);";
                iconColorStyle += "-ms-transform: rotate(" + options.iconRotate + "deg);";
                iconColorStyle += "transform: rotate(" + options.iconRotate + "deg);";
            }
            
            if (options.text) {
                return "<i style='" + iconColorStyle + "' class='" + options.extraClasses + " " + (options.prefix || "") + " " + iconSpinClass + " " + iconColorClass + "'>" + options.text + "</i>";
            }

            return "<i style='" + iconColorStyle + "' class='" + options.extraClasses + " " + (options.prefix || "") + " " + iconClass + " " + iconSpinClass + " " + iconColorClass + "'></i>";
        },

        _setIconStyles: function (img, name) {
            var options = this.options,
                size = L.point(options[name === 'shadow' ? 'shadowSize' : 'iconSize']),
                anchor;

            if (name === 'shadow') {
                anchor = L.point(options.shadowAnchor || options.iconAnchor);
            } else {
                anchor = L.point(options.iconAnchor);
            }

            if (!anchor && size) {
                anchor = size.divideBy(2, true);
            }

            img.className = 'awesome-marker-' + name + ' ' + options.className;

            if (anchor) {
                img.style.marginLeft = (-anchor.x) + 'px';
                img.style.marginTop  = (-anchor.y) + 'px';
            }

            if (size) {
                img.style.width  = size.x + 'px';
                img.style.height = size.y + 'px';
            }
        },

        createShadow: function () {
            var div = document.createElement('div');

            this._setIconStyles(div, 'shadow');
            return div;
        }
    });

    L.AwesomeMarkers.icon = function (options) {
        return new L.AwesomeMarkers.Icon(options);
    };

}(this, document));
