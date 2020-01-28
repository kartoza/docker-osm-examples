define([
    'leaflet',
    'js/data/administrative_level.js',], function (L, AdmLevel) {
    return L.Control.extend({
        selectedClass: 'selected',
        enable: false,
        options: {
            position: 'topleft'
        },
        /**
         * When the control is added on map
         */
        onAdd: function (map) {
            const that = this;
            that.map = map;
            that.administrativeMap = AdmLevel;
            that.layerGroup = L.featureGroup().addTo(map);

            var wrapper = L.DomUtil.create('div', 'leaflet-control-layers');
            L.DomEvent
                .addListener(wrapper, 'click', L.DomEvent.stopPropagation)
                .addListener(wrapper, 'click', L.DomEvent.preventDefault)
                .addListener(wrapper, 'click', function () {
                    let $element = $(this);
                    if ($(this).hasClass(that.selectedClass)) {
                        $element.removeClass(that.selectedClass);
                        that.off();
                    } else {
                        $element.addClass(that.selectedClass);
                        that.on();
                    }
                });

            var inner = L.DomUtil.create('div', 'leaflet-control-custom', wrapper);
            inner.title = 'Create marker to identify location';
            inner.innerHTML = '<i class="fa fa-map-marker" aria-hidden="true"></i>';

            // add the draw and it's event
            that.draw = new L.Draw.Marker(
                map, {draggable: true});
            map.on(L.Draw.Event.CREATED, function (event) {
                if (that.enable) {
                    $(wrapper).click();

                    // add new marker
                    that.layer = event.layer;
                    that.layerGroup.addLayer(that.layer);
                    that.showPopup();
                    that.fetchData()
                }
            });
            return wrapper;
        },
        /**
         * show popup of layer based on data
         * @param data : Array
         */
        showPopup: function (data) {
            let html = '<i class="fa fa-spinner fa-pulse"></i> Loading';
            if (data) {
                html = ''
                data.forEach(x => {
                    if (x.level) {
                        html += `<div><b>${x.level}</b> : ${x.name}</div>`;
                    }
                })
            }
            this.layer.closePopup();
            this.layer.bindPopup(html);
            this.layer.openPopup();
        },
        /**
         * turn on the control
         */
        on: function () {
            this.draw.enable();
            this.enable = true;
            this.layerGroup.clearLayers();
        },
        /**
         * turn off the control
         */
        off: function () {
            this.draw.disable();
            this.enable = false;
            this.layerGroup.clearLayers();
        },
        /**
         * Fetch data based on location of layer
         */
        fetchData: function () {
            // call filters from api
            let latLng = this.layerGroup.getLayers()[0].getLatLng();
            const that = this;
            if (latLng) {
                Request.post(
                    postgresUrl + 'rpc/identify_administrative',
                    {lat: latLng.lat, lng: latLng.lng},
                    'application/json'
                ).done(function (data) {
                    that.showPopup(that.administrativeMap.map(data));
                }).fail(function () {
                    console.log("error");
                });
            }
        }
    })
});