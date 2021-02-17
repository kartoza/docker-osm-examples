var dispatcher;
var Request;
var postgresUrl = 'http://localhost:3000/';
var mapView;

require.config({
    baseUrl: 'js/',
    paths: {
        'jquery': '_libs/jquery.js/3.4.1/jquery.min',
        'jqueryUi': '_libs/jquery-ui-1.12.1/jquery-ui.min',
        'backbone': '_libs/backbone.js/1.4.0/backbone-min',
        'leaflet': '_libs/leaflet/1.5.1/leaflet-src',
        'bootstrap': '_libs/bootstrap/3.3.5/js/bootstrap.min',
        'underscore': '_libs/underscore.js/1.9.1/underscore-min',
        'leafletDraw': '_libs/leaflet.draw/1.0.4/leaflet.draw',
    },
    shim: {
        leaflet: {
            exports: 'L'
        },
        bootstrap: {
            deps: ["jquery"]
        },
        leafletDraw: {
            deps: ['leaflet'],
            exports: 'LeafletDraw'
        },
        utils: {
            deps: ['moment'],
            exports: 'utils'
        }
    }
});
require([
    'jquery',
    'bootstrap',
    'backbone',
    'underscore',
    'leaflet',
    'leafletDraw',
    'js/request.js',
    'js/view/map.js',
    'js/view/side-panel/street-detail.js',
    'js/view/navbar/search-street.js',
], function ($, bootstrap, Backbone, _, L, LDraw, RequestApp, MAP, StreetDetail, SearchStreet) {
    dispatcher = _.extend({}, Backbone.Events);
    Request = RequestApp;
    mapView = new MAP();
    new StreetDetail(mapView.map);
    new SearchStreet();
});
