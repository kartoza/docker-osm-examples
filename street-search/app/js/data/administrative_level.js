define([], function () {
    const mapping = {
        'South Africa': {
            2: 'Country',
            4: 'Region',
            6: 'Settlement',
        }
    }
    return {
        map: function (data) {
            try {
                let country = data[data.length - 1].name;
                const adm = mapping[country];
                $.each(data, function (key, value) {
                    value.level = adm[value.level];
                });
            } catch (e) {

            }
            return data;
        }
    }
});

