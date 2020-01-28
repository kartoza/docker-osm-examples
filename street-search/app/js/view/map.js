define([
    'backbone',
    'jquery',
    'js/data/basemap.js',
    'js/view/controls/identify.js',
], function (Backbone, $, Basemap, Identify) {
    return Backbone.View.extend({
        initBounds: [[-37.335224359306395, 3.6474609375000004], [-19.082884369340157, 44.36279296875]],
        initialize: function () {
            this.map = L.map('map').setView([51.505, -0.09], 13).fitBounds(this.initBounds);
            this.addBasemap();
            this.addControls();
            dispatcher.on('map:fitBounds', this.fitBounds, this);
        },
        /**
         * Add controls to map
         */
        addControls: function () {
            this.map.addControl(new Identify());
        },
        /**
         * Add basemap to map
         */
        addBasemap: function () {
            this.layerControl = L.control.layers(
                Basemap,
                [], {position: 'topleft'});
            L.drawLocal.draw.handlers.marker.tooltip.start = "Place marker to identify location";
            Basemap[Object.keys(Basemap)[0]].addTo(this.map);
            this.layerControl.addTo(this.map);
        },
        /**
         * Fit map to bounds
         */
        fitBounds: function (bounds) {
            this.map.fitBounds(bounds);
        }
    });
});
