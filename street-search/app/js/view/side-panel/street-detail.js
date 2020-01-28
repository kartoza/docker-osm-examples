define([
    'backbone',
    'underscore',], function (Backbone, _) {
    return Backbone.View.extend({
        el: '#side-panel',
        url: postgresUrl + 'osm_roads',
        template: _.template($('#_street-detail').html()),
        mainStreetStyle: {color: 'red', weight: 5},
        intersectedStreetStyle: {color: 'blue', weight: 2},
        initialize: function (map) {
            // create layer
            const that = this;
            this.layer = L.geoJSON(null, {
                onEachFeature: function (feature, layer) {
                    console.log(layer.feature.properties)
                    layer.setStyle(layer.feature.properties.streetType === 'main' ? that.mainStreetStyle : that.intersectedStreetStyle)
                }
            });
            this.layer.addTo(map);
            dispatcher.on('street:detail', this.showDetail, this);
        },
        /**
         * Show detail of street into side panel
         * @param id : id of street
         * @param name : name of street
         * @param data : data of the street that will be showed
         *
         */
        showDetail: function (id, name, data) {
            $(this.el).html(this.template({
                id: id,
                name: name,
                data: data,
            }));
            $(this.el).show('slide', {direction: 'right'});
            if (!data) {
                this.getDetail(id)
            }
        },
        /**
         * Format street data to be layer and also return necessary one
         */
        formatStreetData: function (data, streetType) {
            let geometry = data['geometry'];
            let detailProperty = {
                id: data['id'],
                osm_id: '<a href="https://www.openstreetmap.org/way/' + data['osm_id'] + '">' + data['osm_id'] + '</a>',
                type: data['type'],
                class: data['class'],
                streetType: streetType
            };
            var geojson = {
                "type": "Feature",
                "properties": detailProperty,
                "geometry": geometry
            };
            this.layer.addData(geojson);

            detailProperty = cloneObject(detailProperty);
            delete detailProperty['streetType'];
            return detailProperty;
        },
        /**
         * Get detail of street
         * @param id : id of street
         */
        getDetail: function (id) {
            if (this.xhr) {
                this.xhr.abort();
            }
            this.layer.clearLayers();
            const that = this;
            this.xhr =
                Request.get(
                    this.url,
                    {id: 'eq.' + id},
                    {Accept: 'application/vnd.pgrst.object+json'}
                ).done(function (data) {
                    // create feature and add to map
                    let name = data['name'];
                    let property = that.formatStreetData(data, 'main');
                    dispatcher.trigger('map:fitBounds', that.layer.getBounds());

                    // show detail
                    that.showDetail(id, name, property);
                    that.getIntersection(id);
                }).fail(function () {
                    console.log("error");
                });
        },
        /**
         * Get intersection of street
         * @param id : id of street
         */
        getIntersection: function (id) {
            if (this.xhr) {
                this.xhr.abort();
            }
            const that = this;
            this.xhr = Request.post(
                postgresUrl + 'rpc/street_intersection?order=name',
                {street_id: id},
                'application/json'
            ).done(function (data) {
                let $accordion = $("#accordion");
                let html = 'Not found';
                if (data) {
                    // render template of intersect one
                    let template = _.template($('#_street-detail-data').html());
                    html = '';
                    data.forEach(x => {
                        let name = x['name'];
                        let property = that.formatStreetData(x);
                        html += `
                            <h3>${name}</h3>
                              <div>
                                <p>${template({data: property})}                                
                                </p>
                              </div>`;
                    })
                    dispatcher.trigger('map:fitBounds', that.layer.getBounds());
                }
                $accordion.html(html);
                $accordion.accordion({collapsible: true, active: false})
            }).fail(function () {
                console.log("error");
            });
        }
    })
});