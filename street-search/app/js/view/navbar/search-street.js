define([
    'backbone',
    'leaflet',
    'jqueryUi'], function (Backbone, L, jqueryUi) {
    return Backbone.View.extend({
        el: '#search-street',
        url: postgresUrl + 'osm_roads?select=id,label:name&order=name',
        initialize: function () {
            let that = this;
            $(this.el).autocomplete({
                source: function (request, response) {
                    $(that.el).css("cursor", "wait");
                    Request.get(
                        that.url,
                        {name: 'ilike.*' + request.term + '*'}
                    ).done(function (data) {
                        $(that.el).css("cursor", "text");
                        response(data);
                    }).fail(function () {
                        console.log("error");
                    });
                },
                minLength: 3,
                select: function (event, ui) {
                    dispatcher.trigger('street:detail', ui.item.id, ui.item.label, null);
                },
                open: function () {
                    $(this).removeClass("ui-corner-all").addClass("ui-corner-top");
                },
                close: function () {
                    $(this).removeClass("ui-corner-top").addClass("ui-corner-all");
                }
            });
        }
    })
});